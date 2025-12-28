// 推し付け機能のAjax処理（ハイブリッド方式）
(function() {
  'use strict';

  function initializeRecommendationActions() {
    const actionButtons = document.querySelectorAll('.recommendation-action-btn');
      
    actionButtons.forEach(button => {
      if (button.dataset.listenerAttached === 'true') {
        return;
      }
        
      button.dataset.listenerAttached = 'true';
      const form = button.closest('form');
      if (!form) return;
  
      form.addEventListener('submit', async function(event) {
        event.preventDefault();
        event.stopPropagation();
  
        const action = button.dataset.action;
        const url = form.action;
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
        const card = document.getElementById('recommendation-card');
        const currentStatus = card?.dataset.status;
  
        // 既に選択済みの場合は処理しない
        if (currentStatus !== 'pending') {
          alert('既に選択済みです');
          return;
        }
  
        // ボタンを無効化
        button.disabled = true;
        const originalText = button.innerHTML;
        button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>処理中...';
  
        try {
          const response = await fetch(url, {
            method: 'PATCH',
            headers: {
              'X-CSRF-Token': csrfToken,
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            }
          });
  
          const data = await response.json();
  
          if (data.status === 'success') {
            updateRecommendationUI(data.recommendation_status, data.message);
          } else {
            alert('エラー: ' + data.message);
            button.disabled = false;
            button.innerHTML = originalText;
          }
        } catch (error) {
          console.error('推し付け処理でエラーが発生しました', error);
          alert('処理に失敗しました。ページを再読み込みしてください。');
          button.disabled = false;
          button.innerHTML = originalText;
        }
      });
    });
  }
  
  function updateRecommendationUI(status, message) {
    const selectionButtons = document.getElementById('selection-buttons');
    const resultMessage = document.getElementById('result-message');
    const card = document.getElementById('recommendation-card');
  
    if (!selectionButtons || !resultMessage || !card) return;
  
    // 状態を更新
    card.dataset.status = status;
  
    // 選択ボタンを非表示
    selectionButtons.classList.add('d-none');
  
    // 結果メッセージを表示
    let messageHTML = '';
    if (status === 'favorited') {
      messageHTML = `
        <div class="alert alert-success">
          <i class="bi bi-heart-fill"></i> 
          <strong>${message}</strong>
        </div>
      `;
    } else if (status === 'skipped') {
      messageHTML = `
        <div class="alert alert-secondary">
          <i class="bi bi-skip-forward"></i> 
          <strong>${message}</strong>
        </div>
      `;
    }
  
    const recommendationId = card.dataset.recommendationId;
    const postId = card.dataset.postId;
    const userId = card.dataset.userId;
    const postPath = `/posts/${postId || ''}`;
    const historyPath = `/users/${userId || ''}/recommendations`;
  
    messageHTML += `
      <div class="d-grid gap-2 d-md-flex justify-content-md-center mt-3">
        <a href="${postPath}" class="btn btn-primary">
          <i class="bi bi-arrow-right"></i> 投稿詳細を見る
        </a>
        <a href="${historyPath}" class="btn btn-outline-info">
          <i class="bi bi-clock-history"></i> 履歴を見る
        </a>
      </div>
    `;
  
    resultMessage.innerHTML = messageHTML;
    resultMessage.classList.remove('d-none');
  
    // スムーズにスクロール
    resultMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  
  // イベントリスナーの設定
  document.addEventListener('DOMContentLoaded', initializeRecommendationActions);
  document.addEventListener('turbo:load', initializeRecommendationActions);
  document.addEventListener('turbo:frame-load', initializeRecommendationActions);
})();
  
  