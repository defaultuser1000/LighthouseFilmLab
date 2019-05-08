import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let usersController = UserController()
    try router.register(collection: usersController)
    
    let orderController = OrderController()
    try router.register(collection: orderController)
    
    router.get("register", use: usersController.renderRegister)
    router.post("register", use: usersController.register)
    
    router.get("login", use: usersController.renderLogin)
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.post("login", use: usersController.login)
    
    let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
    protectedRouter.get("profile", use: usersController.renderProfile)
    router.get("logout", use: usersController.logout)
    router.get(use: usersController.renderLogin)
}
