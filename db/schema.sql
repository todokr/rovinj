-- define the relationship between objects and subjects
create table relation_tuples
(
    id                bigserial not null primary key,
    tenant_id         text      not null,
    object_namespace  text      not null,
    object_id         text      not null,
    object_relation   text      not null,
    subject_namespace text      null, -- nullable because only valid if subject set
    subject_id        text      not null,
    subject_relation  text      null, -- only applicable for subject sets

    constraint uq_relation_tuple
        unique (tenant_id,
                object_namespace, object_id, object_relation,
                subject_namespace, subject_id, subject_relation)
);
