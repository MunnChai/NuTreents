class_name NutreentsDiscordRPC
extends Node

## NOTE: Make sure to comment out when building for WEB

static func start() -> void:
	#if ClassDB.class_exists("DiscordRPC"):
		## Application ID
		#DiscordRPC.app_id = 1361572959990579280
		## this is boolean if everything worked
		#print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
		## Set the first custom text row of the activity here
		#DiscordRPC.details = "Growing a forest"
		## Set the second custom text row of the activity here
		##DiscordRPC.state = "Tree gaming"
		## Image key for small image from "Art Assets" from the Discord Developer website
		##DiscordRPC.large_image = "game"
		## Tooltip text for the large image
		##DiscordRPC.large_image_text = "Try it now!"
		## Image key for large image from "Art Assets" from the Discord Developer website
		##DiscordRPC.small_image = "boss"
		## Tooltip text for the small image
		##DiscordRPC.small_image_text = "Fighting the end boss! D:"
		## "02:41 elapsed" timestamp for the activity
		#DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		## "59:59 remaining" timestamp for the activity
		##DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600
		 ## Always refresh after changing the values!
		#DiscordRPC.refresh() 
	pass

static func update_details(details: String) -> void:
	pass
	#if ClassDB.class_exists("DiscordRPC"):
		#DiscordRPC.details = details
		#DiscordRPC.refresh()
