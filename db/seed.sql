delete from relation_tuples where tenant_id = 't1';
/*
user:1 is an owner of doc:323
org:1 is a parent of doc:152
org:1 is an owner of doc:323
user:3 is a member of org:1
user:4 is an admin of org:1
*/
insert into relation_tuples (tenant_id, object_namespace, object_id, object_relation, subject_namespace, subject_id, subject_relation)
values ('t1', 'doc', '323', 'owner', 'user', '1', null),
       ('t1', 'doc', '152', 'parent', 'org', '1', null),
       ('t1', 'doc', '323', 'owner', 'org', '1', 'member'),
       ('t1', 'org', '1', 'member', 'user', '3', null),
       ('t1', 'org', '1', 'admin', 'user', '4', null),
       ('t1', 'org', '2', 'member', 'user', '2', null),

       ('t1', 'org', '1', 'parent', 'org', '10', null),
       ('t1', 'org', '10', 'member', 'user', '4', null)
;

