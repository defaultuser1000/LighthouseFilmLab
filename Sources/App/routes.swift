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
    authSessionRouter.post("login", use: usersController.loginWeb)
    
    let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
    protectedRouter.get("home", use: usersController.renderHome)
    protectedRouter.get("orders", use: orderController.renderOrders)
    protectedRouter.get("orders", "order", Order.parameter, use: orderController.renderOrderDetails)
    protectedRouter.get("users", use: usersController.renderUsers)
    protectedRouter.get("users", "add", use: usersController.renderAddNewUser)
    protectedRouter.post("users", "add", use: usersController.createNewUser)
    protectedRouter.get("settings", use: usersController.renderSettings)
    protectedRouter.get(use: usersController.renderHome)
    protectedRouter.get("orders", "add", use: orderController.renderAddNewOrder)
    protectedRouter.post("orders", "add", use: orderController.createHandler)
    router.get("logout", use: usersController.logout)
}
