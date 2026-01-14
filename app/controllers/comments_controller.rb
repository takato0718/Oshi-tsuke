class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:destroy]
  before_action :check_owner, only: [:destroy]

  # POST /posts/:post_id/comments
  def create
    @comment = @post.comments.build(
      user: current_user,
      reaction_type: :comment,
      content: comment_params[:content]
    )

    if @comment.save
      redirect_to @post, notice: 'コメントを投稿しました'
    else
      error_messages = @comment.errors.full_messages.join(', ')
      redirect_to @post, alert: "コメントの投稿に失敗しました: #{error_messages}"
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    @comment.destroy
    redirect_to @post, notice: 'コメントを削除しました'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def check_owner
    return if @comment.can_be_deleted_by?(current_user)

    redirect_to @post, alert: '権限がありません'
  end

  def comment_params
    params.require(:reaction).permit(:content)
  end
end
