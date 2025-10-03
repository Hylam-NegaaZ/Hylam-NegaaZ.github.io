shader_type canvas_item;

void vertex() {
	UV.x -= TIME * .1;
	UV.y += TIME * .1;
}