% =========================================================================
% Forest Fire Spread Simulation using Cellular Automata in MATLAB
% Capstone Project 2
% =========================================================================

clear; close all; clc;

% --- 1. Simulation Parameters ---
rows = 150;          % Number of rows in the forest grid
cols = 150;          % Number of columns in the forest grid
steps = 300;         % Maximum number of time steps
p_burn = 0.8;        % Probability of a healthy tree catching fire from a neighbor
wind_factor = 0.2;   % Wind bias (e.g., pushes fire towards higher column indices)

% State Definitions:
% 0 = Burnt / Empty
% 1 = Healthy Tree
% 2 = Burning Tree

% --- 2. Grid Initialization ---
% Initialize grid with healthy trees (1)
grid = ones(rows, cols);

% Introduce an initial fire source in the center
center_r = floor(rows / 2);
center_c = floor(cols / 2);
grid(center_r-2:center_r+2, center_c-2:center_c+2) = 2;

% Optional: Introduce some sparse patches (random empty cells, state 0)
empty_prob = 0.05; 
grid(rand(rows, cols) < empty_prob) = 0;
grid(center_r-2:center_r+2, center_c-2:center_c+2) = 2; % Ensure fire is still burning

% --- 3. Visualization Setup ---
% Custom Colormap: [Burnt (Dark Gray), Healthy (Green), Burning (Red-Orange)]
cmap = [0.25 0.25 0.25; ... % 0: Burnt
        0.10 0.65 0.20; ... % 1: Healthy
        1.00 0.30 0.00];    % 2: Burning

figure('Color', 'w', 'Position', [100, 100, 600, 600]);
hImage = imagesc(grid);
colormap(cmap);
caxis([0 2]);
title('Cellular Automata: Forest Fire Spread Simulation', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Columns (East/West)', 'FontSize', 10);
ylabel('Rows (North/South)', 'FontSize', 10);
axis equal tight;
colorbar('Ticks', [0, 1, 2], 'TickLabels', {'Burnt', 'Healthy', 'Burning'});

% --- 4. Simulation Loop ---
for t = 1:steps
    next_grid = grid;
    
    for i = 1:rows
        for j = 1:cols
            current_state = grid(i, j);
            
            if current_state == 2
                % Burning trees transition to burnt (0) in the next step
                next_grid(i, j) = 0;
                
            elseif current_state == 1
                % Healthy tree: Inspect Moore Neighborhood (8 neighbors)
                r_min = max(1, i-1);
                r_max = min(rows, i+1);
                c_min = max(1, j-1);
                c_max = min(cols, j+1);
                
                neighborhood = grid(r_min:r_max, c_min:c_max);
                
                % Check if any immediate neighbor is burning (state 2)
                if any(neighborhood(:) == 2)
                    % Apply stochastic spread rule with optional wind bias
                    % If wind blows towards increasing columns (right), boost probability
                    spread_chance = p_burn;
                    if j < cols && grid(i, j+1) == 2
                        spread_chance = min(1.0, p_burn + wind_factor);
                    end
                    
                    if rand() < spread_chance
                        next_grid(i, j) = 2;
                    end
                end
            end
        end
    end
    
    grid = next_grid;
    
    % Update dynamic visualization
    set(hImage, 'CData', grid);
    drawnow;
    
    % Pause briefly for smooth animation
    pause(0.03);
    
    % Check termination condition: Stop if no burning trees remain
    if ~any(grid(:) == 2)
        fprintf('Simulation ended at step %d: Fire completely extinguished.\n', t);
        break;
    end
end