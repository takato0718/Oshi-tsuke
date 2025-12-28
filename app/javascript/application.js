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
