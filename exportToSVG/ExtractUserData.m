function outList = ExtractUserData(userData)
    
    % this function is only for collecting the data raw, and then returning
    %   a list of the corrected, data. This function should never meddle
    %   with the data, or modify it in any way. Only get the raw data in an
    %   structured array.
    
    % preparing for the iterations-------------------

    outList = {};
    
    movables = userData.movs;
    movableFields = fieldnames(movables);

    dependents = userData.deps;
    dependentFields = fieldnames(dependents);

    % -----------------------------------------------
    
    for i=1:numel(dependentFields)    %Iterating through dependent fields

        elementDataStruct = struct();                   %empty struct for collected data, assigned based on class
        FieldBuffer = dependents.(dependentFields{i});  %actual field of the movables that we are currently working with
        elementDataStruct = ExtractDependentElementData(FieldBuffer, dependentFields{i});

        outList{i} = elementDataStruct;    

    end

    % ------------------------------

    for i=1:numel(movableFields)    %Iterating through movable fields
        
        elementDataStruct = struct();           %empty struct for collected data, assigned based on class
        FieldBuffer = movables.(movableFields{i});   %actual field of the movables that we are currently working with
        elementDataStruct = ExtractMovableElementData(FieldBuffer, movableFields{i});

        outList{(numel(dependentFields) + i)} = elementDataStruct;
        % all the collected data assigned to an index, the indexes are
        % cumulative, so that is why we write to the (numel(dependentFields) + i)
        % index. (we continue from where we left off with the dependent ones
        
    end

end
