% predefined block
num_blocks = 5;
block_names = {'a', 'b', 'c', 'd', 'e'};
block_areas = [2, 3, 4, 3, 5];
area_factor = 0.5;  % Equal area partitioning

% Define specific connections between blocks
connections = [
    0 1 1 0 0;  % a is connected to b and c
    1 0 1 1 0;  % b is connected to a, c, and d
    1 1 0 0 1;  % c is connected to a, b, and e
    0 1 0 0 1;  % d is connected to b and e
    0 0 1 1 0;  % e is connected to c and d
];

fm_vlsi_partition_visualize(num_blocks, block_names, block_areas, area_factor, connections);






function fm_vlsi_partition_visualize(num_blocks, block_names, block_areas, area_factor, connections)
    % Initialize block partitioning: 1st half on left (0), 2nd half on right (1)
    partition = zeros(1, num_blocks);
    partition(ceil(num_blocks / 2) + 1:end) = 1;
    
    % Initial cut cost calculation
    cut_cost = calculate_cut_cost(partition, connections);
    
    % Display initial partitioning
    disp(['Initial partitioning cut cost: ', num2str(cut_cost)]);
    
    % Visualize the partition
    visualize_partition(block_names, block_areas, partition, area_factor);
    
    % FM Algorithm iterations (basic demonstration)
    for iter = 1:5  % Simulate 5 iterations (you can adjust the number of iterations)
        fprintf('\nIteration %d:\n', iter);
        
        % Calculate gains for moving each block
        gains = calculate_gains(partition, connections);
        
        % Find the block with maximum gain
        [~, max_gain_block] = max(gains);
        
        % Move the block to the opposite partition
        partition(max_gain_block) = 1 - partition(max_gain_block);
        
        % Recalculate cut cost after moving the block
        new_cut_cost = calculate_cut_cost(partition, connections);
        
        % Display information about this iteration
        disp(['Moved block ', block_names{max_gain_block}, ' to partition ', num2str(partition(max_gain_block))]);
        disp(['New cut cost: ', num2str(new_cut_cost)]);
        disp(['Gain from move: ', num2str(gains(max_gain_block))]);
        
        % Visualize the updated partition
        visualize_partition(block_names, block_areas, partition, area_factor);
        
        % Update the cut cost
        cut_cost = new_cut_cost;
    end
end

function cut_cost = calculate_cut_cost(partition, connections)
    % Calculate the cut cost based on connections and partition
    cut_cost = 0;
    for i = 1:length(partition)
        for j = i+1:length(partition)
            if connections(i, j) == 1 && partition(i) ~= partition(j)
                cut_cost = cut_cost + 1;  % Increment cost for each cut connection
            end
        end
    end
end

function gains = calculate_gains(partition, connections)
    % Calculate gains for each block: the benefit of moving it to the other partition
    gains = zeros(1, length(partition));
    for i = 1:length(partition)
        same_partition = 0;
        opposite_partition = 0;
        for j = 1:length(partition)
            if connections(i, j) == 1
                if partition(i) == partition(j)
                    same_partition = same_partition + 1;  % Cost in the current partition
                else
                    opposite_partition = opposite_partition + 1;  % Gain if moved
                end
            end
        end
        gains(i) = opposite_partition - same_partition;  % Net gain for moving
    end
end

function visualize_partition(block_names, block_areas, partition, area_factor)
    % Visualize the partitioning of blocks using rectangles
    figure;
    hold on;
    
    % Total area and maximum height to normalize the block sizes
    total_area = sum(block_areas);
    max_height = 1.0;
    
    % Normalized heights of each block
    heights = block_areas / total_area * max_height;
    
    % Plot blocks in their partitions
    left_blocks = find(partition == 0);
    right_blocks = find(partition == 1);
    
    x_pos_left = 0.2;  % X-position for left side
    x_pos_right = 0.8; % X-position for right side
    
    % Plot blocks on the left side
    current_y = 0;  % Starting Y-position
    for i = 1:length(left_blocks)
        b = left_blocks(i);
        rectangle('Position', [x_pos_left, current_y, 0.1, heights(b)], 'FaceColor', rand(1, 3));
        text(x_pos_left + 0.05, current_y + heights(b) / 2, block_names{b}, 'HorizontalAlignment', 'center');
        current_y = current_y + heights(b);
    end
    
    % Plot blocks on the right side
    current_y = 0;
    for i = 1:length(right_blocks)
        b = right_blocks(i);
        rectangle('Position', [x_pos_right, current_y, 0.1, heights(b)], 'FaceColor', rand(1, 3));
        text(x_pos_right + 0.05, current_y + heights(b) / 2, block_names{b}, 'HorizontalAlignment', 'center');
        current_y = current_y + heights(b);
    end
    
    hold off;
    title('Block Partition Visualization');
    xlabel('Partition');
    ylabel('Normalized Block Height');
    axis([0 1 0 1]);  % Set axis limits
end 
