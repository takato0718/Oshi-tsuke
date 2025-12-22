// いいねボタンのAjax処理（Turbo）
(function() {
  'use strict';
    
  function initializeLikeButtons() {
    const likeButtons = document.querySelectorAll('.like-btn');
      
    likeButtons.forEach(button => {
      // 既にイベントリスナーが設定されている場合はスキップ
      if (button.dataset.listenerAttached === 'true') {
        return;
      }
        
      button.dataset.listenerAttached = 'true';
        
      // フォーム要素を取得（button_toで生成されるform）
      const form = button.closest('form');
      if (!form) return;
        
      // Turboのsubmitイベントをキャンセルして、fetch APIで非同期通信
      form.addEventListener('submit', async function(event) {
        event.preventDefault();
        event.stopPropagation();
          
        const formData = new FormData(form);
        const method = formData.get('_method') || form.method.toUpperCase();
        const url = form.action;
        const container = form.closest('.like-button-container');
        const postId = container.dataset.postId;
          
        // ボタンを無効化（連続クリック防止）
        button.disabled = true;
          
        try {
          const response = await fetch(url, {
            method: method,
            headers: {
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: new URLSearchParams(formData)
          });
            
          const data = await response.json();
            
          if (data.status === 'success') {
            // いいね状態を更新
            updateLikeButton(container, data.liked, data.likes_count, postId);
          } else {
            alert('エラー: ' + data.message);
            button.disabled = false;
          }
        } catch (error) {
          console.error('いいね処理でエラーが発生しました', error);
          alert('いいね処理に失敗しました。ページを再読み込みしてください。');
          button.disabled = false;
        }
      });
    });
  }
    
  function updateLikeButton(container, liked, likesCount, postId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
      
    // 新しいボタンを生成
    let formHTML;
    if (liked) {
      // いいね済みの状態（削除ボタン）
      formHTML = `
        <form action="/posts/${postId}/reactions" method="post" data-turbo="false">
          <input type="hidden" name="_method" value="delete">
          <input type="hidden" name="authenticity_token" value="${csrfToken}">
          <button type="submit" class="btn btn-danger like-btn" data-post-id="${postId}" data-liked="true">
            <i class="bi bi-heart-fill"></i> 
            <span class="likes-count">${likesCount}</span>
          </button>
        </form>
        `;
    } else {
      // いいね未済みの状態（作成ボタン）
      formHTML = `
        <form action="/posts/${postId}/reactions" method="post" data-turbo="false">
          <input type="hidden" name="authenticity_token" value="${csrfToken}">
          <button type="submit" class="btn btn-outline-danger like-btn" data-post-id="${postId}" data-liked="false">
            <i class="bi bi-heart"></i> 
            <span class="likes-count">${likesCount}</span>
          </button>
        </form>
      `;
    }
      
    // コンテナの内容を置き換え
    container.innerHTML = formHTML;
      
    // 新しいボタンにイベントリスナーを再設定
    initializeLikeButtons();
  }
    
  // イベントリスナーの設定
  document.addEventListener('DOMContentLoaded', initializeLikeButtons);
  document.addEventListener('turbo:load', initializeLikeButtons);
  document.addEventListener('turbo:frame-load', initializeLikeButtons);
})();
