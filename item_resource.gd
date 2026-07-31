class_name ItemResource extends Resource


enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	GODLY
}


@export var item_rarity: ItemRarity = ItemRarity.COMMON
@export var item_name: String = "Cool Item"
@export var item_desc: String = "its a very cool item"
@export var item_texture: Texture2D
