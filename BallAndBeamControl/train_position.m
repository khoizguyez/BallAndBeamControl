% --- Mã huấn luyện khối E với thuật toán Levenberg-Marquardt (trainlm) ---

% Bước 1: Chuẩn bị dữ liệu huấn luyện cho khối E từ bảng luật mờ
% Dữ liệu gồm đầu vào là error_position (E) và đầu ra tương ứng là angle (U)
training_data_E = [
    -2, -2;
    -1,  1;
     0,  2;
     1, -1;
     2,  1;
];

% Tách dữ liệu đầu vào (E) và đầu ra (U) cho khối E
E_data = training_data_E(:, 1)';   % Đầu vào: error_position
U_data = training_data_E(:, 2)';   % Đầu ra: angle tương ứng

% Chuẩn hóa dữ liệu đầu vào và đầu ra để cải thiện hiệu suất
[E_normalized, E_ps] = mapminmax(E_data, -1, 1);   % Chuẩn hóa E về khoảng [-1, 1]
[U_normalized, U_ps] = mapminmax(U_data, -1, 1);   % Chuẩn hóa U về [-1, 1]

% Bước 2: Khởi tạo mạng neural chỉ với một lớp đầu ra, không có lớp ẩn
net_E = fitnet([]); % Mạng chỉ có lớp đầu ra, không có lớp ẩn

% Cấu hình mạng với thuật toán Levenberg-Marquardt
net_E.trainFcn = 'trainlm';         % Thuật toán Levenberg-Marquardt
net_E.trainParam.epochs = 1000;     % Số lần lặp
net_E.trainParam.goal = 1e-6;       % Ngưỡng lỗi mong muốn
net_E.trainParam.showWindow = true; % Hiển thị cửa sổ huấn luyện
net_E.trainParam.showCommandLine = false; % Tắt hiển thị trên dòng lệnh

% Bước 3: Huấn luyện mạng với dữ liệu của khối E
[net_E, tr_E] = train(net_E, E_normalized, U_normalized);

% Bước 4: Kiểm tra mạng với một ví dụ đầu vào cho khối E
test_E = -2;           % Ví dụ: error_position = -2
test_E_normalized = mapminmax('apply', test_E, E_ps); % Chuẩn hóa đầu vào

% Dự đoán góc angle (U) cho đầu vào đã chuẩn hóa của khối E
predicted_U_normalized = net_E(test_E_normalized);

% Phục hồi giá trị đầu ra về phạm vi gốc
predicted_U = mapminmax('reverse', predicted_U_normalized, U_ps);

% Hiển thị kết quả dự đoán cho khối E
fprintf('Góc dự đoán cho đầu vào E = %d là: %.2f\n', test_E, predicted_U);

% Bước 5: Vẽ biểu đồ lỗi trong quá trình huấn luyện của khối E
figure;
plotperform(tr_E); % Biểu đồ hiệu suất trong quá trình huấn luyện khối E

% Bước 6: Hiển thị cấu trúc mạng neural cho khối E trong MATLAB
view(net_E);

% Tùy chọn thêm: Tạo mô hình Simulink từ mạng neural đã huấn luyện của khối E
gensim(net_E); % Tạo mô hình Simulink từ mạng neural đã huấn luyện của khối E
