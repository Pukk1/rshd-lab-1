DO
$$
    declare
        username       text;
        tab_name       text = 'Н_ЛЮДИ';
        table_id       oid;
        column_record  record;
        column_number  smallint;
        my_column_name text;
        column_type_id oid;
        column_type    text;
        result         text;
        col_constraint text;
    begin
        select current_user into username;
        raise info 'Пользователь: Ivan Kustarev (%)', username;
        raise info 'Таблица: %', tab_name;
        raise info 'No  Имя столбца    Атрибуты';
        raise info '--- -------------- ------------------------------------------';
        select "oid" into table_id from ucheb.pg_catalog.pg_class where "relname" = tab_name;
        for column_record in select * from ucheb.pg_catalog.pg_attribute where attrelid = table_id
            loop
                if column_record.attnum > 0 then
                    column_number = column_record.attnum;
                    my_column_name = column_record.attname;
                    column_type_id = column_record.atttypid;
                    select typname into column_type from ucheb.pg_catalog.pg_type where oid = column_type_id;

                    if column_record.atttypmod != -1 then
                        column_type = column_type || ' (' || column_record.atttypmod || ')';
                    end if;

                    select format('%-3s %-14s %-8s %-2s %s', column_number, my_column_name, 'Type', ':', column_type)
                    into result;
                    raise notice '%', result;

                    select constr.conname
                    from pg_catalog.pg_constraint as constr
                    where column_number = any (constr.conkey)
                    into col_constraint;
                    col_constraint = '"' || col_constraint || '"';

                    if length(col_constraint) > 0 then
                        select format('%-18s %-8s %-2s %s', '-', 'Constr', ':', col_constraint) into result;
                        raise notice '%', result;
                    end if;

                end if;
            end loop;

    end
$$ language 'plpgsql';
