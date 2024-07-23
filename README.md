# Learn_ILP_Memberships_Troubleshooting


# Broken batch uids

## A bit of history

This wiki is inspired in different cases created by Ellucian, in this case I am based on 05408120.

In this case they are referring that a specific user's enrollment could not be removed due to a problem related to ids.

Apparently client needs to work with Support previously and with Ellucian to update several database tables but those we do not do. That is up to Tier 3 and the client. 

The update of those values may sometimes leave some values without update and that is when this becomes a problem.

### BatchUIDs

(You can skip this if you know how those work)

Batch UIDs are the keys used to match a value externally. For example, let's say you have a student, that student has an ID used on your internal system, and when you register that person on Blackboard, it will now have a new ID since we do not match those, however, the BATCH UID can be updated to whatever it is we need, if not entered it will default to the same PK1 as in the users table. This batch UID is usually the value that is used on other systems to link to Blackboard and usually used in Batch operations. (on SIS it is required).

### The problem

Ellucian complains that our mutual client cannot drop several enrollments, they only mention one on the case, but based on previous cases I've worked on, I know this has happened before. They send us like ids and information about the whole enrollment. but it becomes confusing because we are really not so certain about what is that we are looking for. 

### Solving the problem

First, I asked (Even thought they provided that data on the initial description, so, review that first) for the username and the course where the user was enrolled and these are the steps I followed (Most of this steps where made on captain using the query tool)

1. Query for the user's PK1 
`SELECT pk1 FROM users WHERE user_id = '<user_name>'`
2. Query for the Course PK1
`SELECT pk1 FROM course_main WHERE course_id = '<course_id>'`
3. Use both PK1s to query the course_users table, this is the intermediate table that handles memberships
`SELECT PK1 FROM course_users WHERE 
crsmain_pk1 = '<course_pk1_with_no_underscore_just_a_number>' AND
users_pk1 = '<user_pk1_with_no_underscore_just_a_number>'`
4. Query the table that handles the batch UID that should be used when updating values
`SELECT * FROM course_users_uid WHERE course_users_pk1 = '<pk1_from_course_users>'`
5. Query the table to get the mapping between the batch uid and the DSK that has that integration. On this specific case, the value returned as the DSK for that batchUID on the membership didn't match any existing and valid DSKs and that is why it failed.
`SELECT * FROM data_intgr_id_mapping WHERE batch_uid = <BATCH_UID>`

#### Condensed query

Just replace the <<user_name>> value and <<course_id>>

`SELECT dim.*
FROM data_intgr_id_mapping dim
JOIN course_users_uid cui ON dim.batch_uid = cui.batch_uid
JOIN course_users cu ON cui.course_users_pk1 = cu.PK1
JOIN users u ON cu.crsmain_pk1 = u.PK1
JOIN course_main cm ON cu.users_pk1 = cm.PK1
WHERE u.user_id = '<<user_name>>'
  AND cm.course_id = '<<course_id>>';
`


### The result

The result from the last query is the one that we should provide our partner so they can review internally if their mapping is correct, if not, then, client needs to talk with T3 to solve this.

