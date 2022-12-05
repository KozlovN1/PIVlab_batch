function parameter = parse_boolean_conf(conffile)
    parameter = fgetl(conffile);
    if parameter == '1'
        parameter = 'true';
    elseif parameter == '0'
        parameter = 'false';
    end