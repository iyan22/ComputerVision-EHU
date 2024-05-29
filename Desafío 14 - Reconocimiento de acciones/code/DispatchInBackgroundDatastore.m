classdef DispatchInBackgroundDatastore < matlab.io.Datastore
    % DispatchInBackgroundDatastore Datastore to read data in parallel based on NumWorkers.
     
    % Copyright 2020 The MathWorks, Inc.
    properties
        Datastore
        CurrentIndex
        Futures
        FuturesDone
        NumWorkers
        NumPartitions 
        ParallelQueue
        CurrentReadIndex
        Logger
    end

    methods
        function obj = DispatchInBackgroundDatastore(datastore,numWorkers,logger)
            if nargin < 3
                logger = [];
            end
            obj.Datastore = copy(datastore);

            obj.NumPartitions = numpartitions(obj.Datastore);
            obj.NumWorkers = numWorkers;
            obj.Logger = logger;

            reset(obj);
        end

        function reset(obj)
            obj.ParallelQueue = parallel.pool.PollableDataQueue;
            obj.CurrentIndex = 1;
            obj.CurrentReadIndex = 1;
            reset(obj.Datastore);
            setNewFutures(obj);
        end

        function tf = hasdata(obj)
            tf = obj.CurrentIndex <= obj.NumPartitions || ~all(obj.FuturesDone) || obj.ParallelQueue.QueueLength > 0;
        end

        function [data,info] = read(obj)
            if ~hasdata(obj)
                error("No more data. Reset the datastore to read from the start.");
            end
            data = readDataFromQueue(obj);
            info = [];
        end

        function data = preview(obj)
            if ~hasdata(obj.Datastore)
                error("No data present in the datastore.");
            end
            data = preview(obj.Datastore);
        end

        function delete(obj)
            cancelFutures(obj);
            delete(obj.ParallelQueue);
            delete(obj.Datastore);
        end
    end

    methods (Access = private)

        function setNewFutures(obj)
            cancelFutures(obj);
            numFutures = min(obj.NumPartitions,obj.NumWorkers);
            futures(1:numFutures) = parallel.FevalFuture;
            for ii = 1:numFutures
                futures(ii) = createFevalFuture(obj,ii);
            end
            obj.Futures = futures;
            obj.FuturesDone = false(numFutures,1);
        end

        function cancelFutures(obj)
            if ~isempty(obj.Futures) && isa(obj.Futures, 'parallel.FevalFuture')
                cancel(obj.Futures);
            end
        end

        function startDoneFuture(obj, ii)
            if obj.CurrentIndex > obj.NumPartitions
                return;
            end

            obj.FuturesDone(ii) = false;
            obj.Futures(ii) = createFevalFuture(obj, ii);
        end

        function future = createFevalFuture(obj, ii)
            info.Datastore = obj.Datastore;
            info.NumPartitions = obj.NumPartitions;
            info.PartitionIndex = obj.CurrentIndex;
            info.Queue = obj.ParallelQueue;
            info.FutureIndex = ii;
            future = parfeval(@()iReadFromDatastore(info),0);
            obj.CurrentIndex = obj.CurrentIndex + 1;
        end

        function data = readDataFromQueue(obj)
            timeout = 30; % wait for 30 seconds
            [d, OK] = poll(obj.ParallelQueue, timeout);
            if ~OK
                throwErrorOrLog(obj,timeout);
                data = {};
            else
                obj.FuturesDone(d.FutureIndex) = d.Done;
                if d.Done
                    startDoneFuture(obj, d.FutureIndex);
                end
                if isempty(d.Data)
                    warningStr = "Empty data from file: " + obj.Datastore.Files{d.PartitionIndex};
                    warning(warningStr);
                end
                data = d.Data;
                obj.CurrentReadIndex = obj.CurrentReadIndex + 1;
            end
        end

        function tf = areAllFuturesDone(obj)
            tf = all(strcmp({obj.Futures.State}, 'finished'));
        end

        function throwErrorOrLog(obj,timeout)
            futures = obj.Futures;
            errors = vertcat(futures.Error);
            if ~isempty(errors)
                throw(errors(1));
            else

                futuresState = string({obj.Futures.State}).join(",");

                obj.log("Parallel pool did not send any data in the past "  +  timeout + " seconds.");
                obj.log("Are all futures done?: " + areAllFuturesDone(obj));
                obj.log("Futures State?: " + futuresState);
                obj.log("Obj.NumPartitions: " + obj.NumPartitions);
                obj.log("Obj.CurrentReadIndex: " + obj.CurrentReadIndex);
                obj.log("Obj.CurrentIndex: " + obj.CurrentIndex);
                obj.log("Resetting the datastore.");
                reset(obj);
            end
        end

        function log(obj, str)
            if isempty(obj.Logger)
                disp(str);
            else
                obj.Logger.log(str);
            end
        end
    end

    methods(Access = protected)
        function dsCopy = copyElement(ds)
            %COPYELEMENT   Create a deep copy of the datastore
            %   Creates a deep copy of the datastore. Creating a
            %   deep copy allows methods such as readall and
            %   preview, that call the copy method, to remain
            %   stateless.

            % This datastore creates a new copy altogether,
            % without any maintanence of property states.
            cancelFutures(ds);
            dsCopy = DispatchInBackgroundDatastore(ds.Datastore,ds.NumWorkers,ds.Logger);
        end
    end
end

function iReadFromDatastore(info)
    if info.PartitionIndex > info.NumPartitions
        return;
    end


    subds = partition(info.Datastore, info.NumPartitions, info.PartitionIndex);
    while hasdata(subds)
        st=tic;
        d.Data = read(subds);
        d.Elapsed = toc(st);
        d.Done = ~hasdata(subds);
        d.FutureIndex = info.FutureIndex;
        d.PartitionIndex = info.PartitionIndex;
        send(info.Queue,d);
    end
end