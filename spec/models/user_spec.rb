require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '名前、メール、パスワードがあれば有効' do
      user = build(:user)
      expect(user).to be_valid
    end

    it '名前がなければ無効' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include('を入力してください')
    end

    it 'メールアドレスがなければ無効' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('を入力してください')
    end

    it 'メールアドレスが一意でなければ無効' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'パスワードが6文字未満なら無効' do
      user = build(:user, password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('は6文字以上で入力してください')
    end

    it 'パスワードとパスワード確認が一致しなければ無効' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end

  describe 'アソシエーション' do
    it '投稿を持つ' do
      user = create(:user)
      expect(user).to respond_to(:posts)
    end

    it 'コミュニティを持つ' do
      user = create(:user)
      expect(user).to respond_to(:communities)
    end

    it '推し紹介を持つ' do
      user = create(:user)
      expect(user).to respond_to(:recommendations)
    end

    it 'リアクションを持つ' do
      user = create(:user)
      expect(user).to respond_to(:reactions)
    end

    it 'ユーザーを削除すると関連する投稿も削除される' do
      user = create(:user)
      create(:post, user: user)

      expect do
        user.destroy
      end.to change(Post, :count).by(-1)
    end

    it 'ユーザーを削除すると関連するコミュニティも削除される' do
      user = create(:user)
      create(:community, creator: user)

      expect do
        user.destroy
      end.to change(Community, :count).by(-1)
    end
  end

  describe 'OAuth認証' do
    let(:auth) do
      {
        'provider' => 'google_oauth2',
        'uid' => '12345',
        'info' => {
          'name' => 'Test User',
          'email' => 'oauth@example.com',
          'image' => 'https://example.com/avatar.jpg'
        }
      }
    end

    describe '.find_or_create_from_auth' do
      context '新規ユーザーの場合' do
        it 'ユーザーが作成される' do
          expect do
            described_class.find_or_create_from_auth(auth)
          end.to change(described_class, :count).by(1)
        end

        it 'OAuth情報が正しく保存される' do
          user = described_class.find_or_create_from_auth(auth)
          expect(user.provider).to eq('google_oauth2')
          expect(user.uid).to eq('12345')
          expect(user.email).to eq('oauth@example.com')
          expect(user.name).to eq('Test User')
          expect(user.avatar_url).to eq('https://example.com/avatar.jpg')
        end

        it 'パスワードなしで保存される' do
          user = described_class.find_or_create_from_auth(auth)
          # OAuth ユーザーはパスワード認証を使わないことを確認
          expect(user.oauth_user?).to be true
          expect(user.provider).to be_present
          expect(user.uid).to be_present
        end
      end

      context '既存ユーザー(OAuth情報あり)の場合' do
        let!(:existing_user) do
          create(:user,
                 email: 'oauth@example.com',
                 provider: 'google_oauth2',
                 uid: '12345',
                 avatar_url: 'https://old-avatar.com/old.jpg')
        end

        it 'ユーザーが作成されない' do
          expect do
            described_class.find_or_create_from_auth(auth)
          end.not_to change(described_class, :count)
        end

        it '既存ユーザーが返される' do
          user = described_class.find_or_create_from_auth(auth)
          expect(user.id).to eq(existing_user.id)
        end

        it 'ユーザー情報が更新されない' do
          original_name = existing_user.name
          original_avatar = existing_user.avatar_url

          described_class.find_or_create_from_auth(auth)
          existing_user.reload

          expect(existing_user.name).to eq(original_name)
          expect(existing_user.avatar_url).to eq(original_avatar)
        end
      end

      context '既存ユーザー(OAuth情報なし)の場合' do
        let!(:existing_user) do
          create(:user,
                 email: 'oauth@example.com',
                 password: 'password123',
                 password_confirmation: 'password123')
        end

        it 'ユーザーが作成されない' do
          expect do
            described_class.find_or_create_from_auth(auth)
          end.not_to change(described_class, :count)
        end

        it 'OAuth情報が追加される' do
          user = described_class.find_or_create_from_auth(auth)
          expect(user.provider).to eq('google_oauth2')
          expect(user.uid).to eq('12345')
          expect(user.avatar_url).to eq('https://example.com/avatar.jpg')
        end

        it '既存のパスワードは保持される' do
          original_crypted_password = existing_user.crypted_password
          described_class.find_or_create_from_auth(auth)
          existing_user.reload
          expect(existing_user.crypted_password).to eq(original_crypted_password)
        end
      end

      context '異なるメールアドレスでOAuth認証した場合' do
        let!(:existing_user) do
          create(:user,
                 email: 'existing@example.com',
                 provider: 'google_oauth2',
                 uid: '99999')
        end

        it '別の新規ユーザーとして作成される' do
          expect do
            described_class.find_or_create_from_auth(auth)
          end.to change(described_class, :count).by(1)
        end

        it '既存ユーザーとは別のユーザーが返される' do
          user = described_class.find_or_create_from_auth(auth)
          expect(user.id).not_to eq(existing_user.id)
          expect(user.email).to eq('oauth@example.com')
        end
      end

      context 'エラーが発生した場合' do
        before do
          allow(described_class).to receive(:find_by).and_raise(StandardError.new('Database error'))
        end

        it 'nilを返す' do
          result = described_class.find_or_create_from_auth(auth)
          expect(result).to be_nil
        end

        it 'エラーログが出力される' do
          expect(Rails.logger).to receive(:error).with(/OAuth認証エラー/)
          described_class.find_or_create_from_auth(auth)
        end
      end
    end

    describe '#display_avatar' do
      context 'avatar_urlが存在する場合' do
        it 'avatar_urlを返す' do
          user = create(:user, avatar_url: 'https://example.com/avatar.jpg')
          expect(user.display_avatar).to eq('https://example.com/avatar.jpg')
        end
      end

      context 'avatar_urlが存在しない場合' do
        it 'デフォルトアバターのパスを返す' do
          user = create(:user, avatar_url: nil)
          expect(user.display_avatar).to eq('/assets/default_avatar.png')
        end
      end
    end

    describe '#oauth_user?' do
      context 'OAuth認証ユーザーの場合' do
        it 'trueを返す' do
          user = create(:user, provider: 'google_oauth2', uid: '12345')
          expect(user.oauth_user?).to be true
        end
      end

      context '通常登録ユーザーの場合' do
        it 'falseを返す' do
          user = create(:user, provider: nil, uid: nil)
          expect(user.oauth_user?).to be false
        end
      end
    end
  end
end
