extends Node3D
class_name Item

@onready var price_label = $PriceLabel

@export var item_name : String
@export var price : int
@export var is_shop_item : bool = false

func _process(_delta):
	if is_shop_item:
		price_label.text = str(price)

func _on_area_3d_body_entered(body):
	if "Player" in body.name:
		if not is_shop_item:
			body.get_node("HeldItems").pickup(item_name)
			self.queue_free()
		else:
			if body.get_node("HeldItems").money >= price:
				body.get_node("HeldItems").take_money(price)
				body.get_node("HeldItems").pickup(item_name)
				
				var sold_out = load("res://Scenes/Items/item_sold_out.tscn").instantiate()
				get_parent().add_child(sold_out)
				sold_out.position = self.global_position
				
				self.queue_free()
