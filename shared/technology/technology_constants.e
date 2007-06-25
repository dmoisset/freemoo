class TECHNOLOGY_CONSTANTS

feature -- Constants (These have to remain visible to be used in preconditions)

    category_construction: INTEGER is 0
    category_power: INTEGER is 1
    category_chemistry: INTEGER is 2
    category_sociology: INTEGER is 3
    category_computers: INTEGER is 4
    category_biology: INTEGER is 5
    category_physics: INTEGER is 6
    category_force_fields: INTEGER is 7

    is_valid_field_id (field_id: INTEGER): BOOLEAN is
    do
        Result := field_id.in_range(field_min @ 0, field_max @ 7)
    end

    is_valid_tech_id (tech_id: INTEGER): BOOLEAN is
    do
        Result := tech_id.in_range(tech_min @ 0, tech_max @ 7)
    end

feature {} -- Constants
    --
    -- Fields
    -- ~~~~~~
    --

    -- Construction
    field_engineering, field_advanced_engineering, field_advanced_construction,
    field_capsule_construction, field_astro_engineering, field_robotics,
    field_servo_mechanics, field_astro_construction, field_advanced_manufacture,
    field_advanced_robotics, field_tectonic_engineering,
    field_superscalar_construction, field_planetoid_construction,

    -- Power
    field_nuclear_fission, field_cold_fusion, field_advanced_fusion,
    field_ion_fission, field_anti_matter_fission,
    field_matter_energy_conversion,
    field_high_energy_distribution, field_hyper_dimensional_fission,
    field_interphased_fission,

    -- Chemistry
    field_chemistry, field_advanced_metallurgy, field_advanced_chemistry,
    field_molecular_compression, field_nano_technology, field_molecular_manipulation,
    field_molecular_control,

    -- Sociology
    field_military_tactics, field_xeno_relations, field_macro_economics,
    field_teaching_methods, field_advanced_government,
    field_galactic_economics,

    -- Computers
    field_electronics, field_optronics, field_artificial_intelligence,
    field_positronics, field_artificial_consciousness,
    field_cybertronics, field_cybertechnics, field_galactic_networking,
    field_moleculartronics,

    -- Biology
    field_astro_biology, field_advanced_biology, field_genetic_engineering,
    field_genetic_mutation, field_macro_genetics, field_evolutionary_genetics,
    field_artificial_life, field_trans_genetics,

    -- Physics
    field_physics, field_fusion_physics, field_tachyon_physics,
    field_neutrino_physics, field_artificial_gravity,
    field_subspace_physics, field_multiphased_physics, field_plasma_physics,
    field_multidimensional_physics, field_hyperdimensional_physics,
    field_temporal_physics,

    -- Force Fields
    field_advanced_magnetism, field_gravity_fields, field_magneto_gravity,
    field_electromagnetic_refraction, field_warp_fields,
    field_subspace_fields, field_distortion_fields,
    field_quantum_fields, field_transwarp_fields, field_temporal_fields: INTEGER is unique

    field_min: ARRAY[INTEGER] is
    once
        create Result.make (0, 7)
        Result.put (field_engineering, 0)
        Result.put (field_nuclear_fission, 1)
        Result.put (field_chemistry, 2)
        Result.put (field_military_tactics, 3)
        Result.put (field_electronics, 4)
        Result.put (field_astro_biology, 5)
        Result.put (field_physics, 6)
        Result.put (field_advanced_magnetism, 7)
    end

    field_max: ARRAY[INTEGER] is
    do
        create Result.make (0, 7)
        Result.put (field_planetoid_construction, 0)
        Result.put (field_interphased_fission, 1)
        Result.put (field_molecular_control, 2)
        Result.put (field_galactic_economics, 3)
        Result.put (field_moleculartronics, 4)
        Result.put (field_trans_genetics, 5)
        Result.put (field_temporal_physics, 6)
        Result.put (field_temporal_fields, 7)
    end

    --
    -- Technologies
    -- ~~~~~~~~~~~~
    --

    -- Construction: if tech_colony_base is 0,
    tech_colony_base, tech_star_base, tech_marine_barracks,
    tech_anti_missile_rockets, tech_fighter_bays, tech_reinforced_hull,
    tech_automated_factories, tech_missile_base, tech_heavy_armor,
    tech_battle_pods, tech_troop_pods, tech_survival_pods,
    tech_space_port, tech_armor_barracks, tech_fighter_garrison,
    tech_robo_miner_plant, tech_battle_station, tech_powered_armor,
    tech_adv_dmg_control, tech_fast_missile_rack, tech_assault_shuttles,
    tech_titan_construction, tech_ground_batteries, tech_battleoids,
    tech_recyclotron, tech_auto_repair_unit, tech_artificial_planet,
    tech_robotic_factory, tech_bomber_bays,
    tech_deep_core_mine, tech_core_waste_dump,
    tech_star_fortress, tech_adv_city_planning, tech_heavy_fighters,
    tech_doom_star_cnst, tech_artemis_system_net,

    -- Power: then tech_nuclear_drive is 36,
    tech_nuclear_drive, tech_nuclear_bomb, tech_freighters,
    tech_colony_ship, tech_outpost_ship, tech_transport_ship,
    tech_fusion_drive, tech_fusion_bomb, tech_augmented_engines,
    tech_ion_drive, tech_ion_pulse_cannon, tech_shield_capacitor,
    tech_anti_matter_drive, tech_anti_matter_torp, tech_anti_matter_bomb,
    tech_transporters, tech_food_replicator,
    tech_high_energy_focus, tech_energy_absorber, tech_megafluxers,
    tech_proton_torpedo, tech_hyper_drive, tech_hyper_x_capacitor,
    tech_interphased_drive, tech_plasma_torpedo, tech_neutronium_bomb,

    -- Chemistry: tech_nuclear_missile is 62,
    tech_nuclear_missile, tech_standard_fuel_cells, tech_extended_fuel_tank, tech_titanium_armor,
    tech_deuterium_fuel_cells, tech_tritanium_armor,
    tech_merculite_missile, tech_pollution_processor,
    tech_pulson_missile, tech_atmosphere_renewer, tech_iridium_fuel_cells,
    tech_nano_disassemblers, tech_microlite_construction, tech_zortrium_armor,
    tech_zeon_missile, tech_neutronium_armor, tech_urridium_fuel_cells,
    tech_thorium_fuel_cells, tech_adamantium_armor,

    -- Sociology: tech_space_academy is 81,
    tech_space_academy,
    tech_xeno_psychology, tech_alien_cont_center,
    tech_stock_exchange,
    tech_astro_university,
    tech_advanced_government,
    tech_gal_curr_exchange,

    -- Computers: tech_electronic_computer is 88,
    tech_electronic_computer,
    tech_research_lab, tech_optronic_computer, tech_dauntless_guiding_system,
    tech_neural_scanner, tech_scout_lab, tech_security_stations,
    tech_positronic_computer, tech_planetary_supercomputer, tech_holo_simulator,
    tech_emission_guiding_system, tech_rangemaster_unit, tech_cyber_security_link,
    tech_cybertronic_computer, tech_autolab, tech_structural_analyzer,
    tech_android_farmers, tech_android_workers, tech_android_scientist,
    tech_virtual_reality_network, tech_galactic_cybernet,
    tech_pleasure_dome, tech_molecular_computer, tech_achilles_unit,

    -- Biology: tech_hydroponic_farm is 112,
    tech_hydroponic_farm, tech_biospheres,
    tech_cloning_center, tech_soil_enrichment, tech_death_spores,
    tech_telepathic_training, tech_microbiotics,
    tech_terraforming,
    tech_subterranean_farms, tech_weather_controller,
    tech_psionics, tech_heightened_intelligence,
    tech_bio_terminator, tech_universal_antidote,
    tech_biomorphic_fungi, tech_gaia_transformation, tech_evolutionary_mutation,

    -- Physics: tech_laser_cannon is 129
    tech_laser_cannon, tech_laser_rifle, tech_space_scanner,
    tech_fusion_beam, tech_fusion_rifle,
    tech_tachyon_communication, tech_tachyon_scanner, tech_battle_scanner,
    tech_neutron_blaster, tech_neutron_scanner,
    tech_tractor_beam, tech_graviton_beam, tech_gravity_generator,
    tech_subspace_communication, tech_jump_gate,
    tech_phasor, tech_phasor_rifle, tech_multi_phased_shield,
    tech_plasma_cannon, tech_plasma_rifle, tech_plasma_web,
    tech_disruptor_cannon, tech_dimensional_portal,
    tech_hyperspace_communication, tech_sensors, tech_mauler_device,
    tech_time_warp_facillitator, tech_stellar_converter, tech_star_gate,

    -- Force Fields: tech_class_i_shield is 158
    tech_class_i_shield, tech_mass_driver, tech_ecm_jammer,
    tech_anti_grav_garness, tech_innertial_stabilizer, tech_gyro_destabilizer,
    tech_class_iii_shield, tech_radiation_shield, tech_warp_dissipator,
    tech_stealth_field, tech_personal_shield, tech_stealth_suit,
    tech_pulsar, tech_warp_field_interdictor, tech_lightning_field,
    tech_class_v_shield, tech_multi_wave_ecm_jammer, tech_gauss_cannon,
    tech_cloaking_device, tech_stasis_field, tech_hard_shields,
    tech_class_vii_shield, tech_flux_shield, tech_wide_area_jammer,
    tech_displacement_device, tech_subspace_teleporter, tech_inertial_nullifier,
    tech_class_x_shield, tech_barrier_shield, tech_phasing_cloak: INTEGER is unique

    tech_min: ARRAY[INTEGER] is
    once
        create Result.make (0, 7)
        Result.put (tech_colony_base, 0)
        Result.put (tech_nuclear_drive, 1)
        Result.put (tech_nuclear_missile, 2)
        Result.put (tech_space_academy, 3)
        Result.put (tech_electronic_computer, 4)
        Result.put (tech_hydroponic_farm, 5)
        Result.put (tech_laser_cannon, 6)
        Result.put (tech_class_i_shield, 7)
    end

    tech_max: ARRAY[INTEGER] is
    do
        create Result.make (0, 7)
        Result.put (tech_artemis_system_net, 0)
        Result.put (tech_neutronium_bomb, 1)
        Result.put (tech_adamantium_armor, 2)
        Result.put (tech_gal_curr_exchange, 3)
        Result.put (tech_achilles_unit, 4)
        Result.put (tech_evolutionary_mutation, 5)
        Result.put (tech_star_gate, 6)
        Result.put (tech_phasing_cloak, 7)
    end

end -- class TECHNOLOGY_CONSTANTS
