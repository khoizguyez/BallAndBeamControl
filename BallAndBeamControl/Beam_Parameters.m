m = 0.11;       % Khối lượng của quả bóng (kg)
R = 0.15;      % Bán kính của quả bóng (m)
L = 3;         % Chiều dài của thanh (m)
mb = 0.225;    % Khối lượng của thanh (kg)
g = 9.8;      % Gia tốc trọng trường (m/s^2)

% Tính mô-men quán tính của thanh
J = (1/12) * mb * L^2; % Mô-men quán tính của thanh quanh trục giữa (kg*m^2)

% In kết quả ra màn hình
fprintf('Mô-men quán tính của thanh là: %.4f kg*m^2\n', J);
