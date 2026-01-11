import "@hotwired/turbo-rails"
import "./controllers"
import "./validation"
import "./like_button"
import "./recommendation_daily"

// Stimulusアプリケーション開始
import { Application } from "@hotwired/stimulus"
const application = Application.start()

// デバッグ用ログ
console.log("Oshi-tsuke JavaScript loaded! 🚀")
console.log("Turbo and Stimulus ready!")

// 汎用ローディングアニメーション制御
document.addEventListener('turbo:load', () => {
    console.log('Loading animation initialized');
    
      // Turboのナビゲーション開始時にローディング表示
    document.addEventListener('turbo:before-fetch-request', () => {
      showLoading();
    });
    
      // Turboのナビゲーション完了時にローディング非表示
    document.addEventListener('turbo:render', () => {
      hideLoading();
    });
    
      // フォーム送信開始時にローディング表示
    document.addEventListener('turbo:submit-start', () => {
      showLoading();
    });
    
      // フォーム送信完了時にローディング非表示
    document.addEventListener('turbo:submit-end', () => {
      hideLoading();
    });
    
      // エラー発生時にもローディングを非表示
    document.addEventListener('turbo:fetch-request-error', () => {
      hideLoading();
    });
  });
    
    // ローディング表示関数（グローバルに使用可能）
  function showLoading() {
    const overlay = document.getElementById('loading-overlay');
      
    if (overlay) {
      overlay.style.display = 'flex';
      overlay.classList.add('fade-in');
      overlay.classList.remove('fade-out');
        
        // スクロールを無効化
      document.body.style.overflow = 'hidden';
    }
  }
    
    // ローディング非表示関数（グローバルに使用可能）
  function hideLoading() {
    const overlay = document.getElementById('loading-overlay');
      
    if (overlay) {
      overlay.classList.add('fade-out');
      overlay.classList.remove('fade-in');
        
      setTimeout(() => {
        overlay.style.display = 'none';
          // スクロールを再有効化
        document.body.style.overflow = '';
      }, 200);
    }
  }
    
    // グローバルスコープに関数を公開
  window.showLoading = showLoading;
  window.hideLoading = hideLoading;