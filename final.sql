create database hotel_bookings;
use hotel_bookings;

create table Guests(
	guest_id int primary key,
    full_name varchar(255) ,
    email varchar(255) not null unique,
    phone varchar(10) ,
	points int check(points>=0) default 0
);
create table Guest_Profiles(
	profile_id int primary key,
    guest_id int,
    address varchar(255), 
    birthday date,
    national_id int unique,
    foreign key (guest_id) references Guests(guest_id)
);
create table rooms (
    room_id int primary key,
    room_name varchar(50),
    room_type enum('Standard','Deluxe','Suite'),
    price_per_night int check (price_per_night > 0),
    room_status enum('Available','Occupied','Maintenance')
);
create table bookings (
    booking_id int primary key,
    guest_id int,
    room_id int,
    check_in_date datetime,
    check_out_date datetime,
    total_charge decimal(10,2),
    booking_status enum('Pending','Completed','Cancelled'),
    created_at datetime default now(),
    foreign key (guest_id) references guests(guest_id),
    foreign key (room_id) references rooms(room_id)
);
create table Room_Log(
	 log_id int primary key,
     room_id int,
     action_type enum('Check-in','Check-out','Maintenance'),
     change_note varchar(255),
     logged_at datetime,
     foreign key (room_id) references Rooms(room_id)
);

--  Viết script INSERT dữ liệu theo bảng dữ liệu mẫu
insert into Guests 
values 
(1, 'Nguyen Van A', 'anv@gmail.com', '901234567', 150),
(2, 'Tran Thi B', 'btt@gmail.com', '912345678', 500),
(3, 'Le Van C', 'acle@yahoo.com', '922334455', 0),
(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566', 1000),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677', 20);

insert into Guest_Profiles
values
(101, 1, '123 Le Loi, Q1, HCM', '1990-05-15', 12345),
(102, 2, '456 Nguyen Hue, Q1, HCM', '1985-10-20', 23456),
(103, 3, '789 Phan Chu Trinh, Da Nang', '1995-12-01', 34567),
(104, 4, '101 Hoang Hoa Tham, Ha Noi', '1988-03-25', 45678),
(105, 5, '202 Tran Hung Dao, Can Tho', '2000-07-10', 56789);

insert into Rooms 
values 
(1, 'Room 101', 'Standard', 1000000, 'Available'),
(2, 'Room 202', 'Deluxe', 500000, 'Occupied'),
(3, 'Room 303', 'Suite', 5000000, 'Available'),
(4, 'Room 104', 'Standard', 0, 'Occupied'),
(5, 'Room 205', 'Deluxe', 20000000, 'Maintenance');

insert into Bookings
values 
(1001, 1, '2023-11-15 10:30', '2023-11-18 12:00', 35500000, 'Completed'),
(1002, 2, '2023-12-01 14:20', '2023-12-04 12:00', 28000000, 'Completed'),
(1003, 1, '2024-01-10 09:15', '2024-01-11 12:00', 500000, 'Pending'),
(1004, 3, '2023-05-20 16:45', '2023-05-22 12:00', 7000000, 'Cancelled'),
(1005, 4, '2024-01-18 11:00', '2024-01-20 12:00', 1200000, 'Completed');

insert into Room_Log values
(1,1,'Check-in', 'Guest checked in', '2023-10-01 08:00'),
(2,1,'Check-out', 'Guest checked out', '2023-11-15 10:35'),
(3,4,'Maintenance', 'Room reported as damaged', '2023-11-20 15:00'),
(4,2,'Check-in', 'New guest arrival', '2023-11-25 09:00'),
(5,3,'Maintenance', 'Schedule maintenance', '12-1-2023 13:00');

--   Viết câu lệnh UPDATE cộng 200 điểm tích lũy cho các khách hàng có email là đuôi '@gmail.com'
update guests set points = points + 200 where email like '%@gmail.com';

delete from room_log where logged_at < '2023-11-10';
-- TRUY VẤN DỮ LIỆU CƠ BẢN

-- Câu 1 (5đ): Lấy danh sách phòng (room_name, price_per_night, room_status) 
-- có giá thuê > 1.000.000 hoặc room_status = 'Maintenance' hoặc room_type = 'Suite'.
select room_name, price_per_night, room_status from rooms
where price_per_night > 1000000
or room_status = 'maintenance'
or room_type = 'suite';

-- Câu 2 (5đ): Lấy thông tin khách (full_name, email) có email thuộc domain '@gmail.com' 
-- và loyalty_points nằm trong khoảng từ 50 đến 300.
select full_name, email from guests
where email like '%@gmail.com' and points between 50 and 300;

-- Câu 3 (5đ): Hiển thị 3 booking có total_charge cao nhất, sắp xếp giảm dần, 
-- và bỏ qua booking cao nhất (chỉ lấy từ booking thứ 2 → thứ 4). Yêu cầu dùng LIMIT + OFFSET
select * from bookings
order by total_charge desc
limit 3 offset 1;

-- TRUY VẤN DỮ LIỆU NÂNG CAO
-- Câu 1 (6đ): Viết câu lệnh truy vấn lấy ra các thông tin lịch đặt phòng
select g.full_name, gp.national_id, b.booking_id, b.check_in_date, b.total_charge from guests g
join guest_profiles gp on g.guest_id = gp.guest_id
join bookings b on g.guest_id = b.guest_id;

-- Câu 2 (7đ): Tính tổng số tiền thanh toán của mỗi khách. 
-- Chỉ hiển thị các khách có tổng chi tiêu của booking đã hoàn thành > 20.000.000 VNĐ.
select g.full_name, sum(b.total_charge) as total_spent from guests g
join bookings b on g.guest_id = b.guest_id
where b.booking_status = 'completed'
group by g.guest_id
having total_spent > 20000000;

-- - Câu 3 (7đ): Tìm thông tin phòng có price_per_night cao nhất trong danh sách các phòng đã từng xuất hiện trong booking thành công.
select r.* from rooms r
join bookings b on r.room_id = b.room_id
where b.booking_status = 'completed'
order by r.price_per_night desc limit 1;

-- VIEW
create index idx_booking_status_date
on bookings(booking_status, created_at);
-- TRIGGER
-- Câu 1 (5đ): Tạo trigger trg_after_update_booking_status. Khi một booking chuyển trạng thái sang 'Completed', tự động ghi vào Room_Log
delimiter //
create trigger trg_after_update_booking_status
after update on bookings
for each row
begin
    if old.booking_status <> 'completed' and new.booking_status = 'completed' then
        insert into room_log(room_id, action_type, change_note, logged_at)
        values (new.room_id,'check-out','booking completed',now());
    end if;
end//
delimiter ;




-- STORED PROCEDURE
-- - Câu 1 (10đ): Viết Procedure sp_get_room_status nhận vào room_id. Trả về message:
delimiter //
create procedure sp_get_room_status()
begin
	select room_id, room_status from Rooms;
	if room_status ='Available'
end//
	
	







