import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let usersController = UserController()
    try router.register(collection: usersController)
    
    let orderController = OrderController()
    try router.register(collection: orderController)
    
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
