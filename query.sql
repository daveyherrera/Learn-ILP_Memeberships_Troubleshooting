SELECT dim.*
FROM data_intgr_id_mapping dim
JOIN course_users_uid cui ON dim.batch_uid = cui.batch_uid
JOIN course_users cu ON cui.course_users_pk1 = cu.PK1
JOIN users u ON cu.crsmain_pk1 = u.PK1
JOIN course_main cm ON cu.users_pk1 = cm.PK1
WHERE u.user_id = '<<user_name>>'
  AND cm.course_id = '<<course_id>>';
