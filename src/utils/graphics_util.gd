class_name GraphicsUtil extends RefCounted



static func resize_image_texture_to(texture: ImageTexture, width: int, height: int) -> ImageTexture:
	var image := texture.get_image()
	image.resize(width, height, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


static func get_current_sprite_frame_texture(sprite: Sprite2D) -> ImageTexture:
	var atlas := sprite.texture
	var image := atlas.get_image()

	var frame_width := atlas.get_width() / sprite.hframes
	var frame_height := atlas.get_height() / sprite.vframes

	var frame_x := sprite.frame % sprite.hframes
	var frame_y := sprite.frame / sprite.hframes

	var region := Rect2(
		Vector2(frame_x * frame_width, frame_y * frame_height),
		Vector2(frame_width, frame_height)
	)

	var frame_image := image.get_region(region)
	var frame_texture := ImageTexture.create_from_image(frame_image)

	return frame_texture


static func crop_to_used_rect(texture: ImageTexture) -> ImageTexture:
	var image := texture.get_image()
	var used := image.get_used_rect()

	var size := int(max(used.size.x, used.size.y))
	var offset_x := (size - used.size.x) / 2
	var offset_y := (size - used.size.y) / 2

	var square_pos := Vector2i(used.position.x - offset_x, used.position.y - offset_y)

	square_pos.x = clamp(square_pos.x, 0, image.get_width() - size)
	square_pos.y = clamp(square_pos.y, 0, image.get_height() - size)

	var square_region := Rect2i(square_pos, Vector2i(size, size))
	var square_image := image.get_region(square_region)

	return ImageTexture.create_from_image(square_image)
