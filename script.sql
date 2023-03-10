DO
$$
    declare
        username            text;
        tab_name            text = 'actor';
        table_id            oid;
        column_record       record;
        column_number       smallint;
        my_column_name      text;
        column_type_id      oid;
        column_type         text;
        result              text;
        col_constraint_id   oid;
        col_constraint_name text;
        col_constraint_type text;
    begin
        select current_user into username;
        raise info 'Пользователь: Ivan Kustarev (%)', username;
        raise info 'Таблица: %', tab_name;
        raise info 'No  Имя столбца    Атрибуты';
        raise info '--- -------------- ------------------------------------------';
        select "oid" into table_id from pg_catalog.pg_class where "relname" = tab_name;
        for column_record in select * from pg_catalog.pg_attribute where attrelid = table_id
            loop
                if column_record.attnum > 0 then
                    column_number = column_record.attnum;
                    my_column_name = column_record.attname;
                    column_type_id = column_record.atttypid;
                    select typname into column_type from pg_catalog.pg_type where oid = column_type_id;

                    if column_record.atttypmod != -1 then
                        column_type = column_type || ' (' || column_record.atttypmod || ')';
                    end if;

                    select format('%-3s %-14s %-8s %-2s %s', column_number, my_column_name, 'Type', ':', column_type)
                    into result;
                    raise info '%', result;

                    select constr.oid
                    from pg_catalog.pg_constraint as constr
                    where table_id = constr.conrelid
                      and column_number = any (constr.conkey)
                    into col_constraint_id;

                    select constr.conname
                    from pg_catalog.pg_constraint as constr
                    where constr.oid = col_constraint_id
                    into col_constraint_name;
                    col_constraint_name = '"' || col_constraint_name || '"';

                    select constr.contype
                    from pg_catalog.pg_constraint as constr
                    where constr.oid = col_constraint_id
                    into col_constraint_type;

                    if col_constraint_type = 'c' then
                        col_constraint_type = 'check constraint';
                    end if;
                    if col_constraint_type = 'f' then
                        col_constraint_type = 'foreign key constraint';
                    end if;
                    if col_constraint_type = 'p' then
                        col_constraint_type = 'primary key constraint';
                    end if;
                    if col_constraint_type = 'u' then
                        col_constraint_type = 'unique constraint';
                    end if;
                    if col_constraint_type = 't' then
                        col_constraint_type = 'constraint trigger';
                    end if;
                    if col_constraint_type = 'x' then
                        col_constraint_type = 'exclusion constraint';
                    end if;

                    if length(col_constraint_name) > 0 then
                        select format('%-18s %-8s %-2s %s %s', '-', 'Constr', ':', col_constraint_name, col_constraint_type) into result;
                        raise info '%', result;
                    end if;

                end if;
            end loop;

    end
$$ language 'plpgsql';
