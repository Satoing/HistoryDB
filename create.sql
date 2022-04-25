-- 患者
CREATE TABLE patient(
    pno int NOT NULL AUTO_INCREMENT,
    pname char(20) NOT NULL,
    pid char(18) NOT NULL,
    psex char(1) NOT NULL,
    pbd date NULL,
    padd char(50) NULL,
    PRIMARY KEY(pno)
)ENGINE=InnoDB;

-- 联系电话
CREATE TABLE patient_tel(
    ptno int NOT NULL AUTO_INCREMENT,
    pno int NOT NULL,
    pttype char(20) NOT NULL,
    ptcode char(11) NOT NULL,
    PRIMARY KEY(ptno),
    FOREIGN KEY(pno) REFERENCES patient(pno)
)ENGINE=InnoDB;

-- 组织机构
CREATE TABLE dept(
    deptno int NOT NULL,
    deptname char(20) NOT NULL,
    parent_deptno int NULL,
    manager int NULL,
    PRIMARY KEY(deptno),
    FOREIGN KEY(parent_deptno) REFERENCES dept(deptno)
)ENGINE=InnoDB;

-- 医生
CREATE TABLE doctor(
    dno int NOT NULL AUTO_INCREMENT,
    dname char(20) NOT NULL,
    dsex char(1) NOT NULL,
    dage int NOT NULL,
    deptno int NOT NULL,
    tno int NOT NULL,
    PRIMARY KEY(dno),
    FOREIGN KEY(deptno) REFERENCES dept(deptno)
)ENGINE=InnoDB;

ALTER TABLE dept
ADD FOREIGN KEY(manager) REFERENCES doctor(dno);

-- 职称
CREATE TABLE title(
    tno int NOT NULL AUTO_INCREMENT,
    sno int NOT NULL,
    Ttype char(20) NOT NULL,
    Ttrade char(20) NULL,
    PRIMARY KEY(tno)
)ENGINE=InnoDB;

ALTER TABLE doctor
ADD FOREIGN KEY(tno) REFERENCES title(tno);

-- 工资
CREATE TABLE salary(
    sno int NOT NULL AUTO_INCREMENT,
    slevel char(20) NOT NULL,
    snumber decimal(5,0),
    PRIMARY KEY(sno)
)ENGINE=InnoDB;

ALTER TABLE title
ADD FOREIGN KEY(sno) REFERENCES salary(sno);

-- 入库主单
CREATE TABLE godown_entry(
    geno int NOT NULL AUTO_INCREMENT,
    gedate datetime NOT NULL,
    gname char(20) NOT NULL,
    PRIMARY KEY(geno)
)ENGINE=InnoDB;

-- 入库从单
CREATE TABLE godown_slave(
    gsno int NOT NULL AUTO_INCREMENT,
    geno int NOT NULL,
    mno int NOT NULL,
    gsnumber int NOT NULL,
    gsunit char(5) NOT NULL DEFAULT '盒',
    gsprice decimal(8,0) NOT NULL,
    PRIMARY KEY(gsno),
    FOREIGN KEY(geno) REFERENCES godown_entry(geno)
)ENGINE=InnoDB;

-- 药品
CREATE TABLE medicine(
    mno int NOT NULL AUTO_INCREMENT,
    mname char(20) NOT NULL,
    mprice decimal(8,4) NOT NULL,
    munit char(5) NOT NULL DEFAULT '盒',
    mtype char(5) NOT NULL DEFAULT '西药',
    PRIMARY KEY(mno)
)ENGINE=InnoDB;

ALTER TABLE godown_slave
ADD FOREIGN KEY(mno) REFERENCES medicine(mno);

-- 就诊信息
CREATE TABLE diagnosis(
    dgno int NOT NULL AUTO_INCREMENT,
    pno int NOT NULL,
    dno int NOT NULL,
    symptom char(50) NULL,
    diagnosis char(20) NOT NULL,
    dgdate datetime NOT NULL,
    rfee decimal(2,0) NOT NULL,
    PRIMARY KEY(dgno),
    FOREIGN KEY(pno) REFERENCES patient(pno),
    FOREIGN KEY(dno) REFERENCES doctor(dno)
)ENGINE=InnoDB;

-- 处方
CREATE TABLE recipe_master(
    rmno int NOT NULL AUTO_INCREMENT,
    deptno int NOT NULL,
    dno int NOT NULL,
    pno int NOT NULL,
    rmage int NULL,
    rmtime datetime NULL,
    PRIMARY KEY(rmno),
    FOREIGN KEY(deptno) REFERENCES dept(deptno),
    FOREIGN KEY(pno) REFERENCES patient(pno),
    FOREIGN KEY(dno) REFERENCES doctor(dno)
)ENGINE=InnoDB;

-- 处方清单
CREATE TABLE recipe_detail(
    rdno int NOT NULL AUTO_INCREMENT,
    rmno int NOT NULL,
    mno int NOT NULL,
    rdprice decimal(4,1) NOT NULL,
    rdnumber int NOT NULL DEFAULT 1,
    rdunit char(5) NOT NULL DEFAULT '盒',
    PRIMARY KEY(rdno),
    FOREIGN KEY(rmno) REFERENCES recipe_master(rmno),
    FOREIGN KEY(mno) REFERENCES medicine(mno)
)ENGINE=InnoDB;

-- 挂号单
CREATE TABLE register_form(
    rfno int NOT NULL AUTO_INCREMENT,
    deptno int NOT NULL,
    dno int NOT NULL,
    pno int NOT NULL,
    rftime datetime NOT NULL,
    rffee decimal(2,0) NOT NULL,
    rfnotes text NULL,
    PRIMARY KEY(rfno),
    FOREIGN KEY(deptno) REFERENCES dept(deptno),
    FOREIGN KEY(dno) REFERENCES doctor(dno),
    FOREIGN KEY(pno) REFERENCES patient(pno)
)ENGINE=InnoDB;

-- 创建视图
---------------------------------
-- 为消化内科的患者信息建立一个视图
-- 有多张基表，不可修改，只能读取
CREATE VIEW diagview AS
SELECT dgno,patient.pno,pname,doctor.dno,symptom,diagnosis,dgdate
FROM diagnosis,doctor,patient
WHERE diagnosis.dno=doctor.dno
AND patient.pno=diagnosis.pno
AND doctor.deptno=diagnosis.pno
AND doctor.deptno IN(
    SELECT deptno FROM dept WHERE deptname='消化内科'
);

-- 创建医生与患者诊断信息的视图
-- 有多张基表，不可修改，只能读取
CREATE VIEW doctor_patientview AS
SELECT dgno,patient.pno,pname,doctor.dno,dname,symptom,diagnosis,dgdate
FROM diagnosis,doctor,patient
WHERE diagnosis.dno=doctor.dno
AND patient.pno=diagnosis.pno;

-- 统计每名医生每天的诊断工作量
-- 含有GROUP BY,不能修改
CREATE VIEW diagnum(dno,dgdate,patientnum) AS
SELECT recipe_master.dno,rmtime,COUNT(dgno)
FROM recipe_master,diagnosis
GROUP BY recipe_master.dno,rmtime; 

-- 药价提高15%的视图
-- 含有表达式，不能修改
CREATE VIEW medicinenewview(mno,mname,newprice,munit,mtype) AS
SELECT mno,mname,mprice*1.15,munit,mtype
FROM medicine;