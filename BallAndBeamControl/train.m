% --- Mã hoàn chỉnh sử dụng thuật toán tối ưu Levenberg-Marquardt ---

% Bước 1: Chuẩn bị dữ liệu huấn luyện từ bảng luật mờ
train_position = position;
train_velocity = velocity;
train_angle = angle;

% Tách dữ liệu đầu vào (X_train) và đầu ra (y_train)
X_train = [train_position, train_velocity]';  % Đầu vào là error_position và velocity
y_train = train_angle';                        % Đầu ra là góc angle

% Chuẩn hóa dữ liệu đầu vào và đầu ra để cải thiện hiệu suất
[X_train, ps_input] = mapminmax(X_train, -1, 1);  % Chuẩn hóa về khoảng [-1, 1]
[y_train, ps_output] = mapminmax(y_train, -1, 1); % Chuẩn hóa y về [-1, 1]

% Bước 2: Khởi tạo mạng neural với cấu trúc cải tiến
% Cấu trúc mạng với 2 lớp ẩn, mỗi lớp có 15 và 10 nơ-ron
net = fitnet([15, 10]);  % Mạng có 2 lớp ẩn với 15 và 10 neuron

% Cấu hình mạng với thuật toán Levenberg-Marquardt
net.trainFcn = 'trainlm';             % Thuật toán Levenberg-Marquardt
net.trainParam.epochs = 10000;         % Số lần lặp
net.trainParam.goal = 1e-6;           % Ngưỡng lỗi mong muốn
net.trainParam.showWindow = true;     % Hiển thị cửa sổ huấn luyện
net.trainParam.showCommandLine = false; % Tắt hiển thị trên dòng lệnh

% Bước 3: Huấn luyện mạng với dữ liệu huấn luyện
[net, tr] = train(net, X_train, y_train);

% Bước 4: Kiểm tra mạng với một ví dụ đầu vào
test_input = [-2; 0]; % Ví dụ đầu vào: Far_Left và Stationary
test_input = mapminmax('apply', test_input, ps_input); % Chuẩn hóa đầu vào
predicted_angle = net(test_input);
predicted_angle = mapminmax('reverse', predicted_angle, ps_output); % Phục hồi giá trị đầu ra

% Hiển thị kết quả dự đoán
fprintf('Góc dự đoán cho đầu vào [%d, %d] là: %.2f\n', test_input(1), test_input(2), predicted_angle);

% Lựa chọn thêm: Vẽ biểu đồ lỗi trong quá trình huấn luyện
figure;
plotperform(tr); % Biểu đồ hiệu suất trong quá trình huấn luyện

% Lựa chọn thêm: Hiển thị cấu trúc mạng neural trong MATLAB
view(net);
gensim(net); % Tạo mô hình Simulink từ mạng đã huấn luyện
