SELECT 
    shared_models_image.image as filename,
    shared_models_referencecatch.aphia_id,
    shared_models_referencecatch.scientific_name,
    shared_models_referencecatch.code AS strap_code,
    shared_models_sample.sample_number AS set_number,
    shared_models_station.name AS station_name,
    shared_models_sample.start_latitude,
    shared_models_sample.start_longitude
FROM shared_models_image
LEFT JOIN shared_models_sample
ON shared_models_image.sample_id=shared_models_sample.id
LEFT JOIN shared_models_catch
ON shared_models_image.catch_id=shared_models_catch.id
LEFT JOIN shared_models_referencecatch
ON shared_models_catch.reference_catch_id = shared_models_referencecatch.id
LEFT JOIN shared_models_station
ON shared_models_sample.station_id = shared_models_station.id
LEFT JOIN shared_models_mission
ON shared_models_mission.id = shared_models_sample.mission_id
--  need to filter by active mission, this should be done in the R function
-- WHERE shared_models_mission.is_active=1
--  need to filter by complete images only
-- WHERE shared_models_image.complete=1
