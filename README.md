# SWP391_Group1
Git Working Rules cho dự án SWP

Dưới đây là bộ quy tắc Git thường dùng cho project môn SWP để nhóm làm việc rõ ràng, tránh mất code và dễ quản lý tiến độ.

1. Quy tắc Branch
Cấu trúc branch
Branch	Mục đích
main	Source ổn định, chạy được
develop	Branch phát triển chính
feature/...	Làm từng chức năng
bugfix/...	Sửa lỗi
hotfix/...	Fix lỗi gấp trên production/demo
Quy tắc đặt tên branch
Feature
feature/login
feature/manage-user
feature/task-crud
Bugfix
bugfix/login-error
bugfix/null-pointer
Hotfix
hotfix/deploy-error
2. Quy tắc Commit
Nguyên tắc
Commit nhỏ, rõ ràng
Một commit chỉ nên làm 1 việc
Không commit code lỗi
Không commit file rác (bin, obj, .idea, node_modules...)
Format commit
Chuẩn đề xuất
type: short description
Các loại commit thường dùng
Type	Ý nghĩa
feat	Thêm chức năng
fix	Sửa lỗi
refactor	Tối ưu code
ui	Chỉnh giao diện
docs	Tài liệu
test	Test
config	Cấu hình
Ví dụ commit tốt
feat: add login api
feat: create task management screen
fix: resolve null pointer in user service
ui: update dashboard layout
docs: update use case specification
Ví dụ commit không tốt
update
fix bug
aaaa
code mới
3. Quy tắc Pull & Push
Trước khi code

Luôn pull code mới nhất:

git pull origin develop
Sau khi hoàn thành chức năng
git add .
git commit -m "feat: add login function"
git push origin feature/login
4. Quy tắc Merge
Không merge trực tiếp vào main

Flow chuẩn:

feature branch
    ↓
develop
    ↓
main
Merge bằng Pull Request
Người khác review trước khi merge
Test trước khi merge
Không tự merge khi chưa kiểm tra conflict
Sau khi merge

Xóa branch cũ:

git branch -d feature/login
5. Quy tắc Resolve Conflict
Khi conflict
Pull code mới nhất
Đọc kỹ phần conflict
Không xóa nhầm code người khác
Test lại sau khi resolve
Ký hiệu conflict
<<<<<<< HEAD
Code của mình
=======
Code của người khác
>>>>>>> branch-name
6. Quy tắc Backup
Backup bằng GitHub
Push code mỗi ngày
Trước khi nghỉ phải push
Trước demo phải tạo backup
Backup release

Tạo tag:

git tag v1.0
git push origin v1.0
Backup database
Export .sql
Lưu trong folder:
/database/backup/
7. Quy tắc Pull Request
PR cần có
Mô tả chức năng
Ảnh giao diện (nếu có)
Thành viên review
Kiểm tra chạy được
Ví dụ tên PR
[Feature] User Authentication
[Fix] Task Status Bug
8. Quy tắc File & Folder
Không push
node_modules/
bin/
obj/
.vs/
.idea/
.env
Cần có .gitignore

Ví dụ:

node_modules/
bin/
obj/
.vs/
.env