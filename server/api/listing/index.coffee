express = require("express")
controller = require("./listing.controller")
config = include("config/environment")

router = express.Router()

router.get "/", controller.getAll
router.post "/", controller.create
router.get "/:listing_id", controller.getOne
router.put "/:listing_id", controller.update

module.exports = router
