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
    
    router.get { req -> Future<View> in
        struct PageData: Content {
            var users: [User]
            var orders: [Order]
        }
        
        let users = User.query(on: req).all()
        let orders = Order.query(on: req).all()
        
        return flatMap(to: View.self, users, orders) { users, orders in
            let context = PageData(users: users, orders: orders)
            
            return try req.view().render("home", context)
        }
    }
}
