import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let usersController = UserController()
    try router.register(collection: usersController)
    
    let orderController = OrderController()
    try router.register(collection: orderController)
    
    let scannerController = ScannerController()
    try router.register(collection: scannerController)
    
    let settingsController = SettingsController()
    try router.register(collection: settingsController)
    
    let roleController = RoleController()
    try router.register(collection: roleController)
    
    let settingsOrderController = SettingsOrderController()
    try router.register(collection: settingsOrderController)
    
    let orderStatusesController = OrderStatusesController()
    try router.register(collection: orderStatusesController)
    
    let orderFieldController = RoleController()
    try router.register(collection: orderFieldController)
    
    router.get("register", use: usersController.renderRegister)
    router.post("register", use: usersController.register)
    
    router.get("login", use: usersController.renderLogin)
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.post("login", use: usersController.loginWeb)
    
    let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
    protectedRouter.get(use: usersController.renderHome)
    protectedRouter.get("home", use: usersController.renderHome)
    
    protectedRouter.get("orders", use: orderController.renderOrders)
    protectedRouter.get("orders", "add", use: orderController.renderAddNewOrder)
//    protectedRouter.post("orders", "add", use: orderController.testCreateWithPDF)
    protectedRouter.post("orders", "add", use: orderController.createHandler)
    protectedRouter.get("orders", "order", Order.parameter, use: orderController.renderOrderDetails)
    protectedRouter.post("orders", "order", Order.parameter, "next", use: orderController.nextStatusHandlerWeb)
//    protectedRouter.get("orders","order", Order.parameter, "storePdf", use: orderController.storePDF)
    protectedRouter.post("orders", "order", Order.parameter, use: orderController.updateHandlerWeb)
    protectedRouter.get("orders", "order", Order.parameter, "delete", use: orderController.deleteHandlerWeb)
    
    protectedRouter.get("users", use: usersController.renderUsers)
    protectedRouter.get("users", "add", use: usersController.renderAddNewUser)
    protectedRouter.post("users", "add", use: usersController.createNewUser)
    protectedRouter.get("users", "user", User.parameter, use: usersController.renderUserDetails)
    
    protectedRouter.get("settings", use: usersController.renderSettings)
    
    protectedRouter.get("settings", "user", use: settingsController.renderUserSettings)
    protectedRouter.get("settings", "user", "roles", use: roleController.renderRoles)
    protectedRouter.get("settings", "user", "add_new_role", use: roleController.renderAddNewRole)
    protectedRouter.post("settings", "user", "add_new_role", use: roleController.createNewRole)
    protectedRouter.get("settings", "user", "role", Role.parameter, use: roleController.renderRoleDetails)
    
    protectedRouter.get("settings", "order", use: settingsOrderController.renderOrderSettings)
    protectedRouter.get("settings", "order", "statuses", use: orderStatusesController.renderOrderStatuses)
    protectedRouter.get("settings", "order", "statuses", OrderStatus.parameter, use: orderStatusesController.renderOrderStatusDetails)
    protectedRouter.post("settings", "order", "statuses", OrderStatus.parameter, use: orderStatusesController.renderOrderStatusDetails)
    protectedRouter.get("settings", "order", "statuses", "add_new_status", use: orderStatusesController.renderAddNewStatus)
    protectedRouter.post("settings", "order", "statuses", "add_new_status", use: orderStatusesController.createHandlerWeb)
    protectedRouter.get("settings", "order", "fields", use: orderFieldController.renderRoles)
    protectedRouter.get("settings", "order", "fields", "add_new_field", use: orderFieldController.renderRoles)
    protectedRouter.post("settings", "order", "fields", "add_new_field", use: orderFieldController.renderRoles)
    protectedRouter.get("settings", "order", "fields", OrderField.parameter, use: orderFieldController.renderRoles)
    protectedRouter.get("settings", "order", "fields", OrderField.parameter, "add_new_value", use: orderFieldController.renderRoles)
    protectedRouter.post("settings", "order", "fields", OrderField.parameter, "add_new_value", use: orderFieldController.renderRoles)
    
    protectedRouter.get("settings", "scanners", use: scannerController.renderScanners)
    protectedRouter.get("settings", "scanners", "add", use: scannerController.renderAddNewScanner)
    protectedRouter.post("settings", "scanners", "add", use: scannerController.createHandler)
    protectedRouter.get("settings", "scanners", "scanner", Scanner.parameter, use: scannerController.renderScannerDetails)
    protectedRouter.post("settings", "scanners", "scanner", Scanner.parameter, use: scannerController.updateHandlerWeb)
    protectedRouter.post("settings", "scanners", "scanner", Scanner.parameter, "delete", use: scannerController.deleteHandlerWeb)
    
    protectedRouter.get("settings", "add", use: usersController.renderAddNewUser)
    protectedRouter.post("settings", "add", use: usersController.createNewUser)
    protectedRouter.get("settings", "user", User.parameter, use: usersController.renderUserDetails)

    
    router.get("404") { req in
        return try req.view().render("404")
    }
    
    router.get("logout", use: usersController.logout)
}
