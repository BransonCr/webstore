-- Update database for Cursed & Blessed Items Store
USE orders;
GO

-- Clear existing data
DELETE FROM orderproduct;
DELETE FROM productinventory;
DELETE FROM product;
DELETE FROM category;
GO

-- Add new categories
INSERT INTO category(categoryName) VALUES ('Cursed Items');
INSERT INTO category(categoryName) VALUES ('Blessed Items');
INSERT INTO category(categoryName) VALUES ('Forbidden Artifacts');
INSERT INTO category(categoryName) VALUES ('Divine Relics');
GO

-- Cursed Items (explained by Satan from South Park)
INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Cursed Holy Water', 1, 'Blessed by Satan himself! Turns your prayers into curses. Side effects include eternal damnation and mild skin irritation. 16oz bottle of pure evil.', 66.60, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Deafening Earbuds', 1, 'Listen to your favorite music... for the last time! These earbuds permanently destroy your hearing. Perfect for avoiding annoying conversations forever!', 99.99, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Cursed Mirror of Uglification', 1, 'Shows your true inner ugliness on the outside! Warning: May cause permanent facial distortion and self-loathing. No refunds.', 133.70, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Eternal Procrastination Pen', 1, 'Write tomorrow what you should write today! This pen makes you delay everything forever. Comes with infinite writer''s block.', 44.40, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Nightmare Pillow', 1, 'Sleep is for the weak! This pillow guarantees terrifying nightmares every night. Features: sleep paralysis, cold sweats, and demon visitations.', 77.70, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Bad Luck Charm Bracelet', 1, 'Why be lucky when you can be cursed? This bracelet ensures everything goes wrong. Perfect for self-sabotage enthusiasts!', 55.50, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Spoiler-Vision Glasses', 1, 'Ruins every movie, book, and TV show before you experience it! See all spoilers instantly. Friendship destruction guaranteed.', 88.80, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Infinite Hiccup Elixir', 1, 'One sip = hiccups for eternity! Cannot be cured. Not even death will stop the hiccups. Satan''s personal favorite party trick!', 111.10, 'img/satan.png');

-- Blessed Items (blessed by Ramond the Angel)
INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Guaranteed A+ Grade', 2, 'Blessed by Ramond! Automatically gives you an A+ in any course. No studying required! Angel-certified academic success.', 299.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Free Final Exam Solutions', 2, 'Ramond provides divine answers to ALL your final exam questions! Comes with heavenly answer key and guilt-free conscience.', 399.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Instant Knowledge Download', 2, 'Skip the learning process! Ramond downloads 4 years of university knowledge directly into your brain. Warning: May cause enlightenment.', 499.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Homework Auto-Completer', 2, 'Never do homework again! This blessed device completes assignments while you sleep. Ramond''s gift to stressed students.', 249.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Professor Mind Control Ray', 2, 'Make your professor forget about deadlines! Blessed by Ramond to give infinite extensions and grade forgiveness.', 349.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('All-Nighter Prevention Potion', 2, 'Complete weeks of work in minutes! Ramond''s divine efficiency serum. Side effects: Actual productivity and early bedtimes.', 199.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Blessed Calculator of Correct Answers', 2, 'Never get a math problem wrong again! This calculator is blessed by Ramond to always show the right answer, even if you type it wrong.', 149.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Divine Plagiarism Detector Shield', 2, 'Ramond protects your "original" work from detection! Makes Turnitin show 0% similarity. Ethical concerns sold separately.', 279.99, 'img/ramond.png');

-- Forbidden Artifacts (Mix of both)
INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Student Loan Forgiveness Amulet', 3, 'Cursed by Satan, Blessed by Ramond! Makes creditors forget you exist. Side effects: Suspicious phone calls from the IRS.', 666.00, 'img/satan.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Social Anxiety Cure/Curse Ring', 3, 'Blessed to remove social anxiety, cursed to make you overshare EVERYTHING. No filter mode: activated permanently.', 123.45, 'img/ramond.png');

-- Divine Relics
INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Ramond''s Heavenly Coffee Mug', 4, 'Infinite coffee that never runs out! Blessed by Ramond for sleep-deprived students. Warning: May cause transcendent caffeine addiction.', 99.99, 'img/ramond.png');

INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES
('Satan''s Eternal Pizza Box', 4, 'Fresh hot pizza appears whenever you open it! Cursed to make you gain weight from just looking at it. Worth it.', 88.88, 'img/satan.png');

GO

-- Add inventory for all items
DECLARE @i INT = 1;
WHILE @i <= 22
BEGIN
    INSERT INTO productInventory(productId, warehouseId, quantity, price)
    SELECT @i, 1,
        CASE WHEN @i % 3 = 0 THEN 0 ELSE (ABS(CHECKSUM(NEWID())) % 20) + 5 END,
        productPrice
    FROM product WHERE productId = @i;
    SET @i = @i + 1;
END
GO
