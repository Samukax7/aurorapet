extends "res://scripts/battle_pet_actor.gd"

## Ator visual dos Ecos derivados das peças modulares.
## Por padrão olha para o pet com inversão horizontal; a inversão vertical fica disponível
## como opção visual futura, sem confundir o eixo de leitura da batalha.

@export var echo_variant := 1

func configure_echo(source_pet: PetRandomizer = null, horizontal_flip := true, vertical_flip := false) -> void:
	mirror_horizontal = horizontal_flip
	mirror_vertical = vertical_flip
	if source_pet != null:
		set_part_variant(&"eyes", source_pet.eyes_variant)
		set_part_variant(&"ears", source_pet.ears_variant)
		set_part_variant(&"wings", source_pet.wings_variant)
		set_part_variant(&"tail", source_pet.tail_variant)
		if source_pet.palette_pair_index >= 0:
			apply_palette_index(source_pet.palette_pair_index)
		else:
			prepare_development_appearance()
	else:
		prepare_development_appearance()
	_apply_battle_direction()
