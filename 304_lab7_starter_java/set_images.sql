-- Auto-generated mapping of images to products
-- Each statement sets productImageURL to the file under WebContent/img/
-- Run this file with sqlcmd (see instructions below)
USE orders;
GO

UPDATE product SET productImageURL='img/1.jpg' WHERE productId=1;
UPDATE product SET productImageURL='img/10.img' WHERE productId=10;
UPDATE product SET productImageURL='img/11.img' WHERE productId=11;
UPDATE product SET productImageURL='img/12.img' WHERE productId=12;
UPDATE product SET productImageURL='img/13.img' WHERE productId=13;
UPDATE product SET productImageURL='img/14.img' WHERE productId=14;
UPDATE product SET productImageURL='img/15.img' WHERE productId=15;
UPDATE product SET productImageURL='img/16.img' WHERE productId=16;
UPDATE product SET productImageURL='img/17.img' WHERE productId=17;
UPDATE product SET productImageURL='img/18.img' WHERE productId=18;
UPDATE product SET productImageURL='img/19.img' WHERE productId=19;
UPDATE product SET productImageURL='img/2.jpg' WHERE productId=2;
UPDATE product SET productImageURL='img/20.img' WHERE productId=20;
UPDATE product SET productImageURL='img/21.img' WHERE productId=21;
UPDATE product SET productImageURL='img/22.img' WHERE productId=22;
UPDATE product SET productImageURL='img/23.img' WHERE productId=23;
UPDATE product SET productImageURL='img/24.img' WHERE productId=24;
UPDATE product SET productImageURL='img/25.img' WHERE productId=25;
UPDATE product SET productImageURL='img/26.img' WHERE productId=26;
UPDATE product SET productImageURL='img/27.img' WHERE productId=27;
UPDATE product SET productImageURL='img/28.img' WHERE productId=28;
UPDATE product SET productImageURL='img/29.img' WHERE productId=29;
UPDATE product SET productImageURL='img/3.jpg' WHERE productId=3;
UPDATE product SET productImageURL='img/4.jpg' WHERE productId=4;
UPDATE product SET productImageURL='img/5.jpg' WHERE productId=5;
UPDATE product SET productImageURL='img/6.img' WHERE productId=6;
UPDATE product SET productImageURL='img/7.img' WHERE productId=7;
UPDATE product SET productImageURL='img/8.img' WHERE productId=8;
UPDATE product SET productImageURL='img/9.img' WHERE productId=9;

-- Verify (run separately if you prefer):
-- SELECT productId, productImageURL FROM product WHERE productImageURL IS NOT NULL ORDER BY productId;
