# PyMongo : Student Management System (Add, View, Update, Delete) - menu based
# Install:  py -m pip install pymongo
# Run:      py la5-pymongo-student-management.py      (MongoDB server must be running)

from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017/")
db = client["student_db"]
students = db["students"]


def add_student():
    name = input("Name: ")
    age = int(input("Age: "))
    major = input("Major: ")
    grade = input("Grade: ")
    students.insert_one({"name": name, "age": age, "major": major, "grade": grade})
    print("Student added")


def view_students():
    if students.count_documents({}) == 0:
        print("No students")
        return
    for s in students.find({}, {"_id": 0}):
        print(s["name"], s["age"], s["major"], s["grade"])


def update_student():
    name = input("Name of student to update: ")
    major = input("New major: ")
    grade = input("New grade: ")
    r = students.update_one({"name": name}, {"$set": {"major": major, "grade": grade}})
    if r.matched_count == 0:
        print("Student not found")
    else:
        print("Student updated")


def delete_student():
    name = input("Name of student to delete: ")
    r = students.delete_one({"name": name})
    if r.deleted_count == 0:
        print("Student not found")
    else:
        print("Student deleted")


while True:
    print("\n1.Add  2.View  3.Update  4.Delete  5.Exit")
    ch = input("Choice: ")
    if ch == "1":
        add_student()
    elif ch == "2":
        view_students()
    elif ch == "3":
        update_student()
    elif ch == "4":
        delete_student()
    elif ch == "5":
        break
    else:
        print("Invalid choice")

client.close()
