-- Insert sample tournaments
INSERT INTO "311_PCM_Tournaments" (Name, Description, StartDate, EndDate, EntryFee, PrizePool, MaxParticipants, CurrentParticipants, Status, TournamentType, CreatedAt, UpdatedAt)
VALUES 
('Monthly Friendly Match', 'Giải đấu giao hữu hàng tháng. Không đặt nặng thành tích, chủ yếu là vui vẻ.', datetime('now', '+7 days'), datetime('now', '+8 days'), 50000, 1000000, 20, 0, 1, 3, datetime('now'), datetime('now')),
('Spring Open 2026', 'Giải đấu chào xuân 2026 với giải thưởng hấp dẫn. Dành cho trình độ 3.0+.', datetime('now', '+15 days'), datetime('now', '+20 days'), 250000, 6000000, 32, 0, 1, 2, datetime('now'), datetime('now')),
('Winter Cup 2026', 'Giải đấu mùa đông 2026 - Cơ hội tuyệt vời để thể hiện kỹ năng và giao lưu với các thành viên khác.', datetime('now', '+30 days'), datetime('now', '+45 days'), 300000, 8000000, 64, 0, 1, 1, datetime('now'), datetime('now')),
('Elite Padel Cup', 'Giải đấu chuyên nghiệp dành cho các tay vợt hàng đầu. Tranh tài cùng những người giỏi nhất!', datetime('now', '+45 days'), datetime('now', '+50 days'), 500000, 20000000, 16, 0, 1, 1, datetime('now'), datetime('now'));
