import re

with open('consolidated_migrations_and_seeds.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# The script does: IF OBJECT_ID drop Role_Permission... then it tries to insert Role_Permission.
# But Role isn't inserted yet.
# Actually, the easiest way to fix it is just to put "USE TourBuddyDB; GO" at the top of the file,
# and for the foreign key errors, wait! 
# Did it insert Role_Permission in step 1, or did it try to insert it but failed?
# Let's extract the "Seeding Target Users and Roles..." block and move it before the "Role_Permission" inserts!

# Wait, the easiest fix for the TourStatus error was just to run migration_v6.sql before this.
# And the easiest fix for Role_Permission error is to just temporarily disable constraints for Role_Permission!
# Yes! Disable constraints for ALL tables, then enable them at the end.

with open('fix.sql', 'w', encoding='utf-8') as f:
    f.write("USE TourBuddyDB;\nGO\n")
    f.write("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all';\nGO\n")
    f.write(content)
    f.write("\nGO\nEXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all';\nGO\n")

print("Fixed!")
