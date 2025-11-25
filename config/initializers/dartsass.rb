Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

Rails.application.config.dartsass.load_paths = [
  Rails.root.join("node_modules")
]

# 本番環境でのソースマップを無効化
if Rails.env.production?
  Rails.application.config.dartsass.build_options = ["--no-source-map"]
end
