function shortestPathMatrix = bfsShortestPaths(adjacencyMatrix)
    numNodes = size(adjacencyMatrix, 1);
    shortestPathMatrix = zeros(numNodes, numNodes);


    %先对邻接矩阵进行预处理，将对角线上的元素置0
    for i =1:numNodes
        adjacencyMatrix(i,i) = 0;
    end
    
    for sourceNode = 1:numNodes
        visited = false(1, numNodes);
        queue = [];
        visited(sourceNode) = true;
        queue = [queue, sourceNode];
        
        while ~isempty(queue)
            currentNode = queue(1);
            queue(1) = [];
            
            for neighborNode = 1:numNodes
                if adjacencyMatrix(currentNode, neighborNode) == 1 && ~visited(neighborNode)
                    visited(neighborNode) = true;
                    queue = [queue, neighborNode];
                    shortestPathMatrix(sourceNode, neighborNode) = shortestPathMatrix(sourceNode, currentNode) + 1;
                end
            end
        end
    end
end
