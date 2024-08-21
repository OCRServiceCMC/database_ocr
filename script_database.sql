-- Sử dụng database vừa tạo
USE OCR_ServiceDB;

-- Tạo bảng Users
CREATE TABLE [Users] (
  [UserID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng người dùng
  [Username] NVARCHAR(50) NOT NULL UNIQUE, -- Tên đăng nhập của người dùng, phải là duy nhất
  [PasswordHash] NVARCHAR(255) NOT NULL, -- Mã băm của mật khẩu
  [Email] NVARCHAR(100) NOT NULL UNIQUE, -- Địa chỉ email của người dùng, phải là duy nhất
  [CurrentGP] INT NOT NULL DEFAULT 100,
  [Role] NVARCHAR(50) NOT NULL CHECK (Role IN ('ADMIN', 'User', 'Business')), -- Vai trò của người dùng (Admin, User, Business)
  [Status] NVARCHAR(50) NOT NULL CHECK (Status IN ('Active', 'Inactive', 'Locked')), -- Trạng thái tài khoản người dùng (Active, Inactive, Locked)
  [RegistrationDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày đăng ký tài khoản
  [LastLoginDate] DATETIME -- Ngày đăng nhập cuối cùng của người dùng
);

-- Tạo bảng UserRoles
CREATE TABLE [UserRoles] (
  [RoleID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng vai trò
  [RoleName] NVARCHAR(50) NOT NULL UNIQUE -- Tên của vai trò (Admin, User, Business)
);

-- Tạo bảng UserRoleMappings để liên kết Users với UserRoles
CREATE TABLE [UserRoleMappings] (
  [UserID] INT NOT NULL, -- ID của người dùng
  [RoleID] INT NOT NULL, -- ID của vai trò mà người dùng đó được gán
  PRIMARY KEY ([UserID], [RoleID]), -- Khóa chính kết hợp giữa UserID và RoleID
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([RoleID]) REFERENCES [UserRoles]([RoleID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng UserRoles
);

-- Tạo bảng ServicePackages
CREATE TABLE [ServicePackages] (
  [PackageID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng gói dịch vụ
  [PackageName] NVARCHAR(255) NOT NULL, -- Tên của gói dịch vụ
  [Description] NVARCHAR(1000), -- Mô tả về gói dịch vụ
  [Price] DECIMAL(18, 2) NOT NULL, -- Giá của gói dịch vụ
  [DurationInDays] INT NOT NULL, -- Thời hạn sử dụng của gói dịch vụ (tính theo ngày)
  [MaxPages] INT NOT NULL, -- Số trang OCR tối đa được xử lý trong thời hạn của gói dịch vụ
  [IsActive] BIT DEFAULT 1 -- Trạng thái hoạt động của gói dịch vụ (1: Hoạt động, 0: Không hoạt động)
);

-- Tạo bảng UserSubscriptions để lưu thông tin đăng ký dịch vụ của người dùng
CREATE TABLE [UserSubscriptions] (
  [SubscriptionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng đăng ký dịch vụ của người dùng
  [UserID] INT NOT NULL, -- ID của người dùng
  [PackageID] INT NOT NULL, -- ID của gói dịch vụ mà người dùng đăng ký
  [StartDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày bắt đầu đăng ký
  [EndDate] DATETIME NOT NULL, -- Ngày kết thúc đăng ký
  [PagesRemaining] INT NOT NULL, -- Số trang OCR còn lại trong gói dịch vụ
  [AutoRenew] BIT DEFAULT 0, -- Tự động gia hạn gói dịch vụ (1: Có, 0: Không)
  [SubscriptionStatus] NVARCHAR(50) NOT NULL CHECK (SubscriptionStatus IN ('Active', 'Expired', 'Cancelled')), -- Trạng thái của đăng ký (Active, Expired, Cancelled)
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([PackageID]) REFERENCES [ServicePackages]([PackageID]) -- Khóa ngoại liên kết với bảng ServicePackages
);

-- Tạo bảng UserProfile để lưu thông tin hồ sơ người dùng
CREATE TABLE [UserProfile] (
  [ProfileID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho hồ sơ người dùng
  [UserID] INT NOT NULL, -- ID của người dùng
  [FirstName] NVARCHAR(50), -- Tên người dùng
  [LastName] NVARCHAR(50), -- Họ của người dùng
  [Address] NVARCHAR(255), -- Địa chỉ của người dùng
  [PhoneNumber] NVARCHAR(15), -- Số điện thoại của người dùng
  [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày tạo hồ sơ
  [LastLoginDate] DATETIME, -- Ngày đăng nhập cuối cùng của người dùng
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

-- Tạo bảng BusinessProfile để lưu thông tin hồ sơ doanh nghiệp
CREATE TABLE [BusinessProfile] (
  [BusinessID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho hồ sơ doanh nghiệp
  [UserID] INT NOT NULL, -- ID của người dùng (chủ doanh nghiệp)
  [CompanyName] NVARCHAR(100), -- Tên công ty
  [ContactName] NVARCHAR(50), -- Tên người liên hệ của công ty
  [ContactEmail] NVARCHAR(100), -- Email liên hệ của công ty
  [Address] NVARCHAR(255), -- Địa chỉ của công ty
  [PhoneNumber] NVARCHAR(15), -- Số điện thoại liên hệ của công ty
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

-- Tạo bảng PasswordRecovery để lưu thông tin yêu cầu khôi phục mật khẩu
CREATE TABLE [PasswordRecovery] (
  [RecoveryID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi yêu cầu khôi phục mật khẩu
  [UserID] INT NOT NULL, -- ID của người dùng yêu cầu khôi phục mật khẩu
  [RecoveryToken] NVARCHAR(255) NOT NULL, -- Token khôi phục mật khẩu
  [ExpirationDate] DATETIME NOT NULL, -- Ngày hết hạn của token
  [IsUsed] BIT DEFAULT 0, -- Trạng thái token đã được sử dụng hay chưa (1: Đã sử dụng, 0: Chưa sử dụng)
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo yêu cầu khôi phục mật khẩu
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

-- Tạo bảng ServiceContracts để lưu thông tin hợp đồng dịch vụ
CREATE TABLE [ServiceContracts] (
  [ContractID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho hợp đồng dịch vụ
  [UserID] INT NOT NULL, -- ID của người dùng
  [PackageID] INT NOT NULL, -- ID của gói dịch vụ
  [CompanyName] NVARCHAR(255) NOT NULL, -- Tên công ty ký hợp đồng
  [RepresentativeName] NVARCHAR(255) NOT NULL, -- Tên người đại diện công ty
  [Email] NVARCHAR(255) NOT NULL, -- Email liên hệ của công ty
  [Phone] NVARCHAR(50) NULL, -- Số điện thoại liên hệ của công ty (có thể bỏ trống)
  [Address] NVARCHAR(500) NULL, -- Địa chỉ của công ty (có thể bỏ trống)
  [StartDate] DATETIME DEFAULT GETDATE(), -- Ngày bắt đầu hợp đồng
  [EndDate] DATETIME NOT NULL, -- Ngày kết thúc hợp đồng
  [ContractNumber] NVARCHAR(100) NOT NULL, -- Số hợp đồng
  [PaymentStatus] NVARCHAR(50) DEFAULT 'Pending', -- Trạng thái thanh toán của hợp đồng (Pending, Paid)
  [ContractStatus] NVARCHAR(50) DEFAULT 'Active', -- Trạng thái của hợp đồng (Active, Expired, Cancelled)
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo hợp đồng
  [Terms] NVARCHAR(MAX) NOT NULL, -- Điều khoản hợp đồng
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([PackageID]) REFERENCES [ServicePackages]([PackageID]) -- Khóa ngoại liên kết với bảng ServicePackages
);

-- Tạo bảng ContractStatusHistory để lưu lịch sử thay đổi trạng thái hợp đồng
CREATE TABLE [ContractStatusHistory] (
  [StatusHistoryID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho lịch sử trạng thái hợp đồng
  [ContractID] INT NOT NULL, -- ID của hợp đồng
  [OldStatus] NVARCHAR(50) NOT NULL, -- Trạng thái cũ của hợp đồng
  [NewStatus] NVARCHAR(50) NOT NULL, -- Trạng thái mới của hợp đồng
  [ChangedDate] DATETIME DEFAULT GETDATE(), -- Ngày thay đổi trạng thái hợp đồng
  FOREIGN KEY ([ContractID]) REFERENCES [ServiceContracts]([ContractID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng ServiceContracts
);

-- Tạo bảng UploadedFiles để lưu trữ thông tin file được tải lên
CREATE TABLE [UploadedFiles] (
  [FileID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng file được upload
  [UserID] INT NOT NULL, -- ID của người dùng upload file
  [FileName] NVARCHAR(255) NOT NULL, -- Tên file được upload
  [FileType] NVARCHAR(50) CHECK (FileType IN ('PDF', 'JPG', 'PNG')) NOT NULL, -- Loại file (PDF, JPG, PNG)
  [FileSize] BIGINT NOT NULL, -- Kích thước file (tính theo byte)
  [FilePath] NVARCHAR(255),
  [UploadDate] DATETIME DEFAULT GETDATE(), -- Ngày file được upload
  [Processed] BIT DEFAULT 0, -- Trạng thái file đã được xử lý hay chưa (1: Đã xử lý, 0: Chưa xử lý)
  [ProcessedDate] DATETIME NULL, -- Ngày file được xử lý
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

ALTER TABLE [UploadedFiles] DROP CONSTRAINT CK__UploadedF__FileT__656C112C;
ALTER TABLE [UploadedFiles] ADD CONSTRAINT CK__UploadedF__FileT__656C112C
CHECK (FileType IN ('PDF', 'JPG', 'PNG'));

CREATE TABLE [PdfFile](
  [PdfFileID] BIGINT PRIMARY KEY IDENTITY(1,1), -- Sửa lại kiểu dữ liệu để thống nhất với bảng PdfPage
  [FileID] INT NOT NULL,
  [FileName] NVARCHAR(255),
  [Status] NVARCHAR(50),
  [ProcessedDate] DATETIME NULL, -- Ngày xử lý trang
  FOREIGN KEY ([FileID]) REFERENCES [UploadedFiles]([FileID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng UploadedFiles
);

CREATE TABLE [PdfPage](
  [PdfPageID] BIGINT PRIMARY KEY IDENTITY(1,1), -- Giữ nguyên kiểu dữ liệu BIGINT để phù hợp với PdfFileID trong bảng PdfFile
  [PdfFileID] BIGINT NOT NULL, -- Đảm bảo kiểu dữ liệu đồng nhất với PdfFile.PdfFileID
  [PageNumber] INT,
  [Data] VARBINARY,
  [ProcessedData] VARBINARY(MAX),
  FOREIGN KEY ([PdfFileID]) REFERENCES [PdfFile]([PdfFileID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng PdfFile
);

-- Tạo bảng ProcessingLogs để lưu trữ thông tin nhật ký xử lý file
CREATE TABLE [ProcessingLogs] (
  [LogID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng nhật ký xử lý
  [FileID] INT NOT NULL, -- ID của file đã được xử lý
  [UserID] INT NOT NULL,
  [ActionType] NVARCHAR(100) NOT NULL, -- Loại hành động xử lý (e.g., OCR, Rotate)
  [ActionDetails] NVARCHAR(1000) NULL, -- Chi tiết về hành động xử lý
  [ActionDate] DATETIME DEFAULT GETDATE(), -- Ngày thực hiện hành động xử lý
  [IsSuccess] BIT DEFAULT 1, -- Trạng thái thành công hay thất bại của hành động (1: Thành công, 0: Thất bại)
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([FileID]) REFERENCES [UploadedFiles]([FileID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng UploadedFiles
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE NO ACTION -- Khóa ngoại liên kết với bảng UploadedFiles
);

-- Tạo bảng RecognizedTexts để lưu trữ văn bản được nhận dạng từ file
CREATE TABLE [RecognizedTexts] (
  [TextID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho văn bản nhận dạng
  [FileID] INT NOT NULL, -- ID của file đã nhận dạng văn bản
  [RecognizedText] NVARCHAR(MAX) NOT NULL, -- Văn bản được nhận dạng từ file
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo văn bản nhận dạng
  FOREIGN KEY ([FileID]) REFERENCES [UploadedFiles]([FileID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng UploadedFiles
);

-- Tạo bảng ContractPromotions để lưu thông tin khuyến mãi của hợp đồng
CREATE TABLE [ContractPromotions] (
  [PromotionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho khuyến mãi hợp đồng
  [ContractID] INT NOT NULL, -- ID của hợp đồng
  [DiscountCode] NVARCHAR(50) NULL, -- Mã giảm giá (nếu có)
  [DiscountAmount] DECIMAL(18, 2) NULL, -- Số tiền giảm giá (nếu có)
  [ExpirationDate] DATETIME NULL, -- Ngày hết hạn của khuyến mãi (nếu có)
  FOREIGN KEY ([ContractID]) REFERENCES [ServiceContracts]([ContractID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng ServiceContracts
);

-- Tạo bảng FolderUploads để lưu trữ thông tin các thư mục được tải lên
CREATE TABLE [FolderUploads] (
  [FolderID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng thư mục upload
  [UserID] INT NOT NULL, -- ID của người dùng upload thư mục
  [FolderName] NVARCHAR(255) NOT NULL, -- Tên thư mục
  [UploadDate] DATETIME DEFAULT GETDATE(), -- Ngày thư mục được upload
  [Processed] BIT DEFAULT 0, -- Trạng thái thư mục đã được xử lý hay chưa (1: Đã xử lý, 0: Chưa xử lý)
  [ProcessedDate] DATETIME NULL, -- Ngày thư mục được xử lý
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

-- Tạo bảng FolderFiles để lưu trữ thông tin các file trong thư mục
CREATE TABLE [FolderFiles] (
  [FolderFileID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng file trong thư mục
  [FolderID] INT NOT NULL, -- ID của thư mục chứa file
  [FileID] INT NOT NULL, -- ID của file trong thư mục
  FOREIGN KEY ([FolderID]) REFERENCES [FolderUploads]([FolderID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng FolderUploads, giữ lại CASCADE
  FOREIGN KEY ([FileID]) REFERENCES [UploadedFiles]([FileID]) ON DELETE NO ACTION -- Thay đổi thành NO ACTION để tránh multiple cascade paths
);

-- Tạo bảng Document để lưu trữ thông tin tài liệu
CREATE TABLE [Document] (
  [DocumentID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng tài liệu
  [UserID] INT NOT NULL, -- ID của người dùng tạo tài liệu
  [FileID] INT NULL, -- ID của file liên kết với tài liệu này (có thể là NULL nếu tài liệu không liên kết với file nào)
  [DocumentName] NVARCHAR(255) NOT NULL, -- Tên tài liệu
  [DocumentType] NVARCHAR(50) NOT NULL, -- Loại tài liệu (e.g., PDF, DOCX)
  [UploadDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày tạo tài liệu
  [Status] NVARCHAR(50) NOT NULL, -- Trạng thái của tài liệu (e.g., Active, Inactive)
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]), -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([FileID]) REFERENCES [UploadedFiles]([FileID]) ON DELETE NO ACTION -- Tránh multiple cascade paths bằng cách sử dụng NO ACTION
);

-- Tạo bảng UserActions để lưu trữ các hành động của người dùng trên tài liệu
CREATE TABLE [UserActions] (
  [ActionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng hành động của người dùng
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện hành động
  [ActionType] NVARCHAR(50) NOT NULL CHECK (ActionType IN ('Upload', 'Download', 'Delete')), -- Loại hành động (Upload, Download, Delete)
  [ActionDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày thực hiện hành động
  [DocumentID] INT NOT NULL, -- ID của tài liệu liên quan đến hành động
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Document
);

-- Tạo bảng PDFOperationsLog để lưu trữ các thao tác trên tài liệu PDF
CREATE TABLE [PDFOperationsLog] (
  [OperationID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho từng nhật ký thao tác PDF
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện thao tác
  [DocumentID] INT NOT NULL, -- ID của tài liệu liên quan đến thao tác
  [OperationType] NVARCHAR(50) NOT NULL CHECK (OperationType IN ('Delete Page', 'Split Page', 'Rotate Page')), -- Loại thao tác (Delete Page, Split Page, Rotate Page)
  [PageIDs] NVARCHAR(255) NULL, -- Danh sách các PageID liên quan đến thao tác (nếu có)
  [OperationDate] DATETIME DEFAULT GETDATE(), -- Ngày thực hiện thao tác
  [Status] NVARCHAR(50) DEFAULT 'Completed' CHECK (Status IN ('Completed', 'Failed')), -- Trạng thái của thao tác (Completed, Failed)
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Document
);

-- Tạo bảng TextSearchEntries để lưu trữ các mục tìm kiếm văn bản
CREATE TABLE [TextSearchEntries] (
  [EntryID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi mục tìm kiếm văn bản
  [DocumentID] INT NOT NULL, -- ID của tài liệu chứa văn bản được tìm kiếm
  [RecognizedText] NVARCHAR(MAX) NOT NULL, -- Văn bản được nhận dạng và lưu trữ
  [SearchIndexID] NVARCHAR(255) NULL, -- ID của văn bản trong ElasticSearch (nếu có)
  [IsIndexed] BIT DEFAULT 0, -- Trạng thái văn bản đã được index hay chưa (1: Đã index, 0: Chưa index)
  [IndexedDate] DATETIME NULL, -- Ngày văn bản được index (nếu có)
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Document
);

-- Tạo bảng FileConversions để lưu trữ thông tin chuyển đổi file
CREATE TABLE [FileConversions] (
  [ConversionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi lần chuyển đổi file
  [DocumentID] INT NOT NULL, -- ID của tài liệu liên quan đến chuyển đổi file
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện chuyển đổi
  [TargetFormat] NVARCHAR(50) NOT NULL CHECK (TargetFormat IN ('JPG', 'PDF', 'DOCX', 'XLSX')), -- Định dạng mục tiêu của file sau khi chuyển đổi
  [ConversionStatus] NVARCHAR(50) DEFAULT 'Pending' CHECK (ConversionStatus IN ('Pending', 'In Progress', 'Completed', 'Failed')), -- Trạng thái chuyển đổi
  [ConversionDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày thực hiện chuyển đổi
  [ResultFileID] INT NULL, -- ID của file kết quả sau khi chuyển đổi (nếu có)
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]), -- Khóa ngoại liên kết với bảng Document
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]), -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([ResultFileID]) REFERENCES [Document]([DocumentID]) ON DELETE NO ACTION -- Thay đổi thành NO ACTION để tránh multiple cascade paths
);

-- Tạo bảng OCRRequests để lưu trữ thông tin yêu cầu OCR
CREATE TABLE [OCRRequests] (
  [RequestID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi yêu cầu OCR
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện yêu cầu OCR
  [DocumentID] INT NOT NULL, -- ID của tài liệu liên quan đến yêu cầu OCR
  [RequestDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo yêu cầu OCR
  [RequestType] NVARCHAR(50) NOT NULL CHECK (RequestType IN ('Handwriting', 'Text Extraction', 'Overlay Detection', 'Invalid Detection')), -- Loại yêu cầu OCR
  [Status] NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Failed')), -- Trạng thái yêu cầu OCR
  [Result] NVARCHAR(MAX) NULL, -- Kết quả của yêu cầu OCR (nếu có)
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Document
);

-- Tạo bảng ChatbotInteractions để lưu trữ thông tin tương tác với chatbot
CREATE TABLE [ChatbotInteractions] (
  [InteractionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi tương tác với chatbot
  [UserID] INT NOT NULL, -- ID của người dùng tương tác với chatbot
  [DocumentID] INT NOT NULL, -- ID của tài liệu liên quan đến tương tác
  [QueryText] NVARCHAR(MAX) NOT NULL, -- Câu hỏi hoặc yêu cầu của người dùng gửi đến chatbot
  [ResponseText] NVARCHAR(MAX) NULL, -- Phản hồi của chatbot
  [InteractionDate] DATETIME DEFAULT GETDATE(), -- Ngày diễn ra tương tác
  [InteractionType] NVARCHAR(50) NOT NULL CHECK (InteractionType IN ('Summarize', 'Extract Info', 'Translate')), -- Loại tương tác (Summarize, Extract Info, Translate)
  [Status] NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Completed', 'Failed')), -- Trạng thái tương tác
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([DocumentID]) REFERENCES [Document]([DocumentID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Document
);

-- Tạo bảng OCRResults để lưu trữ kết quả OCR
CREATE TABLE [OCRResults] (
  [ResultID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi kết quả OCR
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến kết quả
  [ResultText] NVARCHAR(MAX) NULL, -- Kết quả nhận dạng dưới dạng văn bản
  [ResultPDF] VARBINARY(MAX) NULL, -- Kết quả nhận dạng dưới dạng file PDF
  [ResultJSON] NVARCHAR(MAX) NULL, -- Kết quả nhận dạng dưới dạng file JSON
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo kết quả OCR
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng OCRCharges để lưu trữ các khoản phí OCR
CREATE TABLE [OCRCharges] (
  [OCRChargeID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi khoản phí OCR
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến khoản phí
  [ChargeDate] DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày tính phí
  [Amount] MONEY NOT NULL, -- Số tiền phí OCR
  [Description] NVARCHAR(50) DEFAULT 'Pending' CHECK (Description IN ('Pending', 'Processing', 'Completed', 'Failed')), -- Mô tả về khoản phí
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng ExtractedAttributes để lưu trữ thông tin thuộc tính trích xuất từ file
CREATE TABLE [ExtractedAttributes] (
  [AttributeID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi thuộc tính trích xuất được
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến thuộc tính
  [AttributeName] NVARCHAR(255) NOT NULL, -- Tên thuộc tính trích xuất được (e.g., PhoneNumber, Name)
  [AttributeValue] NVARCHAR(255) NOT NULL, -- Giá trị của thuộc tính trích xuất được
  [ExtractedDate] DATETIME DEFAULT GETDATE(), -- Ngày trích xuất thuộc tính
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng OverlayDetections để lưu trữ thông tin phát hiện chồng lấp
CREATE TABLE [OverlayDetections] (
  [DetectionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi phát hiện chồng lấp
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến phát hiện chồng lấp
  [DetectionType] NVARCHAR(50) NOT NULL, -- Loại phát hiện chồng lấp (e.g., Handwriting Overlay, Text Overlay)
  [DetectionDetails] NVARCHAR(1000) NULL, -- Chi tiết về phát hiện chồng lấp
  [DetectedDate] DATETIME DEFAULT GETDATE(), -- Ngày phát hiện chồng lấp
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng InvalidDocumentDetections để lưu trữ thông tin phát hiện tài liệu không hợp lệ
CREATE TABLE [InvalidDocumentDetections] (
  [InvalidDetectionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi phát hiện tài liệu không hợp lệ
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến phát hiện tài liệu không hợp lệ
  [DetectionDetails] NVARCHAR(1000) NULL, -- Chi tiết phát hiện tài liệu không hợp lệ
  [DetectedDate] DATETIME DEFAULT GETDATE(), -- Ngày phát hiện tài liệu không hợp lệ
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng CorrectionRequests để lưu trữ thông tin yêu cầu sửa lỗi
CREATE TABLE [CorrectionRequests] (
  [CorrectionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi yêu cầu sửa lỗi
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến yêu cầu sửa lỗi
  [CorrectionTool] NVARCHAR(50) NOT NULL CHECK (CorrectionTool IN ('ChatGPT', 'Gemini')), -- Công cụ sửa lỗi được sử dụng (e.g., ChatGPT, Gemini)
  [CorrectedText] NVARCHAR(MAX) NULL, -- Văn bản sau khi sửa lỗi
  [CorrectionStatus] NVARCHAR(50) DEFAULT 'Pending' CHECK (CorrectionStatus IN ('Pending', 'Completed', 'Failed')), -- Trạng thái của yêu cầu sửa lỗi
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo yêu cầu sửa lỗi
  [CompletedDate] DATETIME NULL, -- Ngày hoàn thành sửa lỗi (nếu có)
  [ErrorMessage] NVARCHAR(1000) NULL, -- Thông báo lỗi nếu có
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng RecognitionFees để lưu trữ thông tin phí nhận dạng
CREATE TABLE [RecognitionFees] (
  [FeeID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi khoản phí nhận dạng
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến khoản phí nhận dạng
  [PageCount] INT NOT NULL, -- Số trang đã nhận dạng
  [FeeAmount] DECIMAL(18, 2) NOT NULL, -- Số tiền phí nhận dạng
  [FeeDate] DATETIME DEFAULT GETDATE(), -- Ngày tính phí
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRRequests
);

-- Tạo bảng FeeHistory để lưu trữ lịch sử phí nhận dạng
CREATE TABLE [FeeHistory] (
  [HistoryID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho lịch sử phí nhận dạng
  [FeeID] INT NOT NULL, -- ID của khoản phí nhận dạng
  [FeeAmount] DECIMAL(18, 2) NOT NULL, -- Số tiền phí,
  [Description] VARCHAR(255) NULL, -- Mô tả về khoản phí,
  [FeeDate] DATETIME DEFAULT GETDATE(), -- Ngày tính phí,
  FOREIGN KEY ([FeeID]) REFERENCES RecognitionFees(FeeID) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng RecognitionFees
);

-- Tạo bảng FileDownloads để lưu trữ thông tin tải file
CREATE TABLE [FileDownloads] (
  [DownloadID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi lần tải file
  [ResultID] INT NOT NULL, -- ID của kết quả OCR liên quan đến việc tải file
  [DownloadDate] DATETIME DEFAULT GETDATE(), -- Ngày tải file
  [DownloadType] NVARCHAR(50) NOT NULL CHECK (DownloadType IN ('Converted File', 'Processed PDF')), -- Loại file tải về (Converted File, Processed PDF)
  [Status] NVARCHAR(50) DEFAULT 'Completed' CHECK (Status IN ('Completed', 'Failed')), -- Trạng thái của việc tải file (Completed, Failed)
  FOREIGN KEY ([ResultID]) REFERENCES [OCRResults]([ResultID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng OCRResults
);

-- Tạo bảng Transactions để lưu trữ thông tin giao dịch
CREATE TABLE [Transactions] (
  [TransactionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi giao dịch
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện giao dịch
  [RequestID] INT NOT NULL, -- ID của yêu cầu OCR liên quan đến giao dịch
  [TransactionDate] DATETIME DEFAULT GETDATE(), -- Ngày thực hiện giao dịch
  [DocumentType] NVARCHAR(100), -- Loại tài liệu liên quan đến giao dịch
  [OCRResultSummary] NVARCHAR(MAX), -- Tóm tắt kết quả OCR liên quan đến giao dịch
  [TransactionStatus] NVARCHAR(50) NOT NULL CHECK (TransactionStatus IN ('Success', 'Processing', 'Failed')), -- Trạng thái giao dịch (Success, Processing, Failed)
  [FileSizeInBytes] BIGINT, -- Kích thước file liên quan đến giao dịch (nếu có)
  [FilePath] NVARCHAR(255), -- Đường dẫn đến file gốc liên quan đến giao dịch (nếu có)
  [ResultFilePath] NVARCHAR(255), -- Đường dẫn đến file kết quả liên quan đến giao dịch (nếu có)
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]), -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([RequestID]) REFERENCES [OCRRequests]([RequestID]) ON DELETE NO ACTION -- Thay đổi thành NO ACTION để tránh multiple cascade paths
);

-- Tạo bảng GPTransactions để lưu trữ thông tin giao dịch GP
CREATE TABLE [GPTransactions] (
  [GPTransactionID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi giao dịch GP
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện giao dịch GP
  [PackageID] INT NOT NULL, -- ID của gói dịch vụ liên quan đến giao dịch GP
  [GPUsed] INT NOT NULL, -- Số lượng GP đã sử dụng trong giao dịch
  [TransactionDate] DATETIME DEFAULT GETDATE(), -- Ngày thực hiện giao dịch GP
  [TransactionStatus] NVARCHAR(50) NOT NULL CHECK (TransactionStatus IN ('Success', 'Failed')), -- Trạng thái giao dịch GP (Success, Failed)
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE, -- Khóa ngoại liên kết với bảng Users
  FOREIGN KEY ([PackageID]) REFERENCES [ServicePackages]([PackageID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng ServicePackages
);

-- Drop the foreign key constraint on PackageID
ALTER TABLE [GPTransactions] DROP CONSTRAINT FK__GPTransac__Packa__662B2B3B;

-- Drop the PackageID column
ALTER TABLE [GPTransactions] DROP COLUMN [PackageID];

-- Thêm cột
-- Add the new CurrentGP column with a default value of 100
ALTER TABLE [GPTransactions] 
ADD [CurrentGP] INT NOT NULL DEFAULT 100;



-- Tạo bảng Payments để lưu trữ thông tin thanh toán
CREATE TABLE [Payments] (
  [PaymentID] INT PRIMARY KEY IDENTITY(1,1), -- ID duy nhất cho mỗi lần thanh toán
  [UserID] INT NOT NULL, -- ID của người dùng thực hiện thanh toán
  [Amount] DECIMAL(18, 2) NOT NULL, -- Số tiền thanh toán
  [PaymentMethod] NVARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Card', 'Momo')), -- Phương thức thanh toán (Card, Momo)
  [TransactionReference] NVARCHAR(255), -- Mã giao dịch từ Momo hoặc mã Seri thẻ cào (nếu có)
  [PaymentDate] DATETIME DEFAULT GETDATE(), -- Ngày thanh toán
  [PaymentStatus] NVARCHAR(50) NOT NULL CHECK (PaymentStatus IN ('Success', 'Failed')), -- Trạng thái thanh toán (Success, Failed)
  [GPAmount] INT NOT NULL, -- Số lượng GP nhận được từ thanh toán
  [CreatedDate] DATETIME DEFAULT GETDATE(), -- Ngày tạo giao dịch thanh toán
  FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID]) ON DELETE CASCADE -- Khóa ngoại liên kết với bảng Users
);

CREATE TABLE [InvalidTokens] (
    [ID] BIGINT PRIMARY KEY IDENTITY(1,1),
    [Token] VARCHAR(500) NOT NULL,
    [ExpirationDate] DATETIME NOT NULL
);
