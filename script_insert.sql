USE OCR_ServiceDB;

-- Bảng Users
INSERT INTO [Users] ([Username], [PasswordHash], [Email], [Role], [Status])
VALUES
('admin', 'hashed_password_1', 'admin@example.com', 'ADMIN', 'Active'),
('user1', 'hashed_password_2', 'user1@example.com', 'User', 'Active'),
('user2', 'hashed_password_3', 'user2@example.com', 'Business', 'Inactive');

-- Bảng UserRoles
INSERT INTO [UserRoles] ([RoleName])
VALUES
('ADMIN'),
('User'),
('Business');

-- Bảng UserRoleMappings
INSERT INTO [UserRoleMappings] ([UserID], [RoleID])
VALUES
(1, 1), -- admin
(2, 2), -- user1
(3, 3); -- user2

-- Bảng ServicePackages
INSERT INTO [ServicePackages] ([PackageName], [Description], [Price], [DurationInDays], [MaxPages])
VALUES
('Basic Package', 'Basic OCR package', 9.99, 30, 100),
('Pro Package', 'Pro OCR package', 19.99, 30, 500),
('Enterprise Package', 'Enterprise OCR package', 49.99, 30, 2000);

-- Bảng UserSubscriptions
INSERT INTO [UserSubscriptions] ([UserID], [PackageID], [EndDate], [PagesRemaining], [AutoRenew], [SubscriptionStatus])
VALUES
(1, 1, DATEADD(day, 30, GETDATE()), 100, 0, 'Active'),
(2, 2, DATEADD(day, 30, GETDATE()), 500, 1, 'Active'),
(3, 3, DATEADD(day, 30, GETDATE()), 2000, 1, 'Expired');

-- Bảng UserProfile
INSERT INTO [UserProfile] ([UserID], [FirstName], [LastName], [Address], [PhoneNumber])
VALUES
(1, 'Admin', 'User', '123 Admin St.', '1234567890'),
(2, 'John', 'Doe', '456 User Ave.', '0987654321'),
(3, 'Jane', 'Smith', '789 Business Rd.', '1122334455');

-- Bảng BusinessProfile
INSERT INTO [BusinessProfile] ([UserID], [CompanyName], [ContactName], [ContactEmail], [Address], [PhoneNumber])
VALUES
(3, 'ABC Corp', 'Jane Smith', 'contact@abccorp.com', '789 Business Rd.', '1122334455');

-- Bảng PasswordRecovery
INSERT INTO [PasswordRecovery] ([UserID], [RecoveryToken], [ExpirationDate])
VALUES
(1, 'token_1', DATEADD(day, 1, GETDATE())),
(2, 'token_2', DATEADD(day, 1, GETDATE())),
(3, 'token_3', DATEADD(day, 1, GETDATE()));

-- Bảng UploadedFiles
INSERT INTO [UploadedFiles] ([UserID], [FileName], [FileType], [FileSize])
VALUES
(1, 'file1.pdf', 'PDF', 102400),
(2, 'file2.jpg', 'JPG', 204800),
(3, 'file3.png', 'PNG', 307200);

-- Bảng ProcessingLogs
INSERT INTO [ProcessingLogs] ([FileID], [ActionType], [ActionDetails])
VALUES
(1, 'OCR', 'Performed OCR on file1.pdf'),
(2, 'Rotate', 'Rotated file2.jpg by 90 degrees'),
(3, 'Enhance', 'Enhanced brightness of file3.png');

-- Bảng Document
INSERT INTO [Document] ([UserID], [FileID], [DocumentName], [DocumentType], [Status])
VALUES
(1, 1, 'Document1', 'PDF', 'Active'),
(2, 2, 'Document2', 'JPG', 'Inactive'),
(3, 3, 'Document3', 'PNG', 'Active');

-- Bảng RecognizedTexts
INSERT INTO [RecognizedTexts] ([FileID], [RecognizedText])
VALUES
(1, 'Recognized text from file1.pdf'),
(2, 'Recognized text from file2.jpg'),
(3, 'Recognized text from file3.png');

-- Bảng ContractPromotions
INSERT INTO [ContractPromotions] ([ContractID], [DiscountCode], [DiscountAmount], [ExpirationDate])
VALUES
(1, 'PROMO10', 10.00, DATEADD(day, 30, GETDATE())),
(2, 'PROMO20', 20.00, DATEADD(day, 15, GETDATE()));

-- Bảng FilePages
INSERT INTO [FilePages] ([FileID], [PageNumber], [PageContent], [IsProcessed])
VALUES
(1, 1, 0x255044462D312E350D0A25E2E3CFD30D0A312030206F626A0D0A, 1),
(2, 1, 0x255044462D312E350D0A25E2E3CFD30D0A312030206F626A0D0A, 0);

-- Bảng FolderUploads
INSERT INTO [FolderUploads] ([UserID], [FolderName], [Processed], [ProcessedDate])
VALUES
(1, 'Folder1', 1, GETDATE()),
(2, 'Folder2', 0, NULL);

-- Bảng FolderFiles
INSERT INTO [FolderFiles] ([FolderID], [FileID])
VALUES
(1, 1),
(2, 2);

-- Bảng PDFPages
INSERT INTO [PDFPages] ([FileID], [PageNumber], [OriginalPageContent], [ProcessedPageContent], [RotationAngle])
VALUES
(1, 1, 0x255044462D312E350D0A25E2E3CFD30D0A312030206F626A0D0A, NULL, 0),
(2, 2, 0x255044462D312E350D0A25E2E3CFD30D0A312030206F626A0D0A, NULL, 90);

-- Bảng UserActions
INSERT INTO [UserActions] ([UserID], [ActionType], [DocumentID])
VALUES
(1, 'Upload', 1),
(2, 'Download', 2);

-- Bảng PDFOperationsLog
INSERT INTO [PDFOperationsLog] ([UserID], [DocumentID], [OperationType], [PageIDs], [Status])
VALUES
(1, 1, 'Rotate Page', '1,2,3', 'Completed'),
(2, 2, 'Delete Page', '2', 'Failed');

-- Bảng TextSearchEntries
INSERT INTO [TextSearchEntries] ([DocumentID], [RecognizedText], [SearchIndexID], [IsIndexed])
VALUES
(1, 'Recognized text for document 1', 'index1', 1),
(2, 'Recognized text for document 2', 'index2', 0);

-- Bảng FileConversions
INSERT INTO [FileConversions] ([DocumentID], [UserID], [TargetFormat], [ConversionStatus], [ResultFileID])
VALUES
(1, 1, 'PDF', 'Completed', 1),
(2, 2, 'DOCX', 'Failed', NULL);

-- Bảng OCRRequests
INSERT INTO [OCRRequests] ([UserID], [DocumentID], [RequestType], [Status])
VALUES
(1, 1, 'Text Extraction', 'Completed'),
(2, 2, 'Handwriting', 'Pending');

-- Bảng ChatbotInteractions
INSERT INTO [ChatbotInteractions] ([UserID], [DocumentID], [QueryText], [ResponseText], [InteractionType], [Status])
VALUES
(1, 1, 'Summarize this document', 'This document is about...', 'Summarize', 'Completed'),
(2, 2, 'Translate this text', NULL, 'Translate', 'Pending');

-- Bảng OCRResults
INSERT INTO [OCRResults] ([RequestID], [ResultText], [ResultPDF], [ResultJSON])
VALUES
(1, 'Recognized text here', NULL, '{"result": "success"}'),
(2, NULL, 0x255044462D312E350D0A25E2E3CFD30D0A312030206F626A0D0A, NULL);

-- Bảng OCRCharges
INSERT INTO [OCRCharges] ([RequestID], [Amount], [Description])
VALUES
(1, 100.00, 'Completed'),
(2, 50.00, 'Pending');

-- Bảng ExtractedAttributes
INSERT INTO [ExtractedAttributes] ([RequestID], [AttributeName], [AttributeValue])
VALUES
(1, 'PhoneNumber', '123-456-7890'),
(2, 'Name', 'John Doe');

-- Bảng OverlayDetections
INSERT INTO [OverlayDetections] ([RequestID], [DetectionType], [DetectionDetails])
VALUES
(1, 'Handwriting Overlay', 'Detected handwriting overprinted text'),
(2, 'Text Overlay', 'Detected printed text overlay');

-- Bảng InvalidDocumentDetections
INSERT INTO [InvalidDocumentDetections] ([RequestID], [DetectionDetails])
VALUES
(1, 'Detected invalid text format'),
(2, 'Detected missing sections');

-- Bảng CorrectionRequests
INSERT INTO [CorrectionRequests] ([RequestID], [CorrectionTool], [CorrectionStatus], [CorrectedText])
VALUES
(1, 'ChatGPT', 'Completed', 'Corrected text here'),
(2, 'Gemini', 'Pending', NULL);

-- Bảng RecognitionFees
INSERT INTO [RecognitionFees] ([RequestID], [PageCount], [FeeAmount])
VALUES
(1, 10, 100.00),
(2, 5, 50.00);

-- Bảng FeeHistory
INSERT INTO [FeeHistory] ([FeeID], [FeeAmount], [Description])
VALUES
(1, 100.00, 'First fee entry'),
(2, 50.00, 'Second fee entry');

-- Bảng FileDownloads
INSERT INTO [FileDownloads] ([ResultID], [DownloadType], [Status])
VALUES
(1, 'Converted File', 'Completed'),
(2, 'Processed PDF', 'Failed');

-- Bảng Transactions
INSERT INTO [Transactions] ([UserID], [RequestID], [DocumentType], [TransactionStatus])
VALUES
(1, 1, 'Image', 'Success'),
(2, 2, 'PDF', 'Failed');

-- Bảng GPTransactions
INSERT INTO [GPTransactions] ([UserID], [PackageID], [GPUsed], [TransactionStatus])
VALUES
(1, 1, 100, 'Success'),
(2, 2, 50, 'Failed');

-- Bảng Payments
INSERT INTO [Payments] ([UserID], [Amount], [PaymentMethod], [TransactionReference], [PaymentStatus], [GPAmount])
VALUES
(1, 100.00, 'Momo', 'MO123456789', 'Success', 100),
(2, 50.00, 'Card', 'CA987654321', 'Failed', 50);
