// Import and register all your controllers
import { application } from "./application"

// Import and register all your controllers manually
import HelloController from "./hello_controller"
application.register("hello", HelloController)
