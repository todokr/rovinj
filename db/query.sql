-- name: QueryRelationShips :many
select
    rt.object_relation,
    rt.subject_namespace,
    rt.subject_id,
    rt.subject_relation
from relation_tuples rt
where
    rt.tenant_id = 't1'
and rt.object_namespace = 'doc'
and rt.object_id = '323'
;


with recursive relation_tree as (
    select
        rt.object_relation,
        rt.subject_namespace,
        rt.subject_id,
        rt.subject_relation,
        jsonb_build_array(jsonb_build_object(
            'object_namespace', rt.object_namespace,
            'object_id', rt.object_id,
            'object_relation', rt.object_relation,
            'subject_namespace', rt.subject_namespace,
            'subject_id', rt.subject_id,
            'subject_relation', rt.subject_relation)) as path,
        0 as hops
    from relation_tuples rt
    where
        rt.tenant_id = @tenant_id::text
    and rt.object_namespace = @object_namespace::text
    and rt.object_id = @object_id::text
    union all
    select
        rt.object_relation,
        rt.subject_namespace,
        rt.subject_id,
        rt.subject_relation,
        jsonb_build_array(jsonb_build_object(
            'object_namespace', rt.object_namespace,
            'object_id', rt.object_id,
            'object_relation', rt.object_relation,
            'subject_namespace', rt.subject_namespace,
            'subject_id', rt.subject_id,
            'subject_relation', rt.subject_relation)) || r.path,
        r.hops + 1
    from relation_tuples rt
    join relation_tree r on r.subject_namespace = rt.object_namespace
                        and r.subject_id = rt.object_id
                        and rt.tenant_id = @tenant_id::text
                        and r.hops + 1 < @max_hops::int
)
select
    rt.object_relation,
    rt.subject_namespace,
    rt.subject_id,
    rt.hops
from relation_tree rt
where rt.subject_namespace = @subject_namespace::text
;

with recursive relation_tree as (
    select
        rt.object_namespace,
        rt.object_id,
        rt.object_relation,
        rt.subject_namespace,
        rt.subject_id,
        rt.subject_relation,
        array [rt.object_namespace || '.' || rt.object_id || '#' || rt.object_relation || '@' || rt.subject_namespace || '.' || rt.subject_id || coalesce('#' || rt.subject_relation, '')] as path,
        1 as hops
    from relation_tuples rt
    where
        rt.tenant_id = 't1'
      and rt.object_namespace = 'doc'
      and rt.object_id = '323'
    union all
    select
        rt.object_namespace,
        rt.object_id,
        rt.object_relation,
        rt.subject_namespace,
        rt.subject_id,
        rt.subject_relation,
        r.path || array [rt.object_namespace || '.' || rt.object_id || '#' || rt.object_relation || '@' || rt.subject_namespace || '.' || rt.subject_id || coalesce('#' || rt.subject_relation, '')],
        r.hops + 1
    from relation_tuples rt
             join relation_tree r on r.subject_namespace = rt.object_namespace
        and r.subject_id = rt.object_id
        and rt.tenant_id = 't1'
        and r.hops + 1 <= 2
)
select
    rt.subject_namespace,
    rt.subject_id,
    rt.path,
    rt.hops
from relation_tree rt
where rt.subject_namespace = 'user'
;
