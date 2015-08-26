import hashlib
import datetime
import time
import json

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, Float, String, Text, DateTime
from sqlalchemy.orm import sessionmaker, scoped_session

_sess = None
session = None

def _createDB():
#    engine = create_engine('sqlite:///:memory:', echo=False)
#     engine = create_engine('sqlite:///foo.db', echo=False)
    # string with DB connection details
    connection = 'mysql://USER:PASS@HOST/DATABASE'
    engine = create_engine(connection, convert_unicode=True)
#    session = sessionmaker()
    session = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session.configure(bind=engine)
    Base.metadata.create_all(engine)

    return session

def openDB():
    global session
    if session == None:
        session = _createDB()

    # db_session = scoped_session(session)
    return session()

#------------------------------------------------------------------------------------

Base = declarative_base()


class User(Base):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True)
    email = Column(String(16), unique=True)
    passwd = Column(String(16))
    name = Column(String(16))
    address = Column(String(16))
    occupation = Column(String(16))
    year_hunting = Column(Integer)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow)

    def __init__(self, _id, email, passwd, name, address, occupation, year_hunting):
        self.id = _id
        self.email = email
        self.passwd = passwd
        self.name = name
        self.address = address
        self.occupation = occupation
        self.year_hunting = year_hunting

    def todict(self):
        d = {}
        for column in self.__table__.columns:
            if isinstance(getattr(self, column.name), datetime.datetime):
                d[column.name] = str(getattr(self, column.name))
            else:
                d[column.name] = getattr(self, column.name)
        return d


class Sighting(Base):
    __tablename__ = 'sighting'

    id = Column(Integer, primary_key=True)
    no_of_adults = Column(Integer)
    no_of_calves = Column(Integer)
    unusual_observations = Column(Text)
    lat = Column(Float)
    lon = Column(Float)
    vsigns = Column(Text)
    created_by = Column(String(16))

    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow)

    def __init__(self, _id, an, na, nc, uo, lat, lon, vsigns, bywho):
        self.id = _id
        self.animal_name = an
        self.no_of_adults = na
        self.no_of_calves = nc
        self.unusual_observations = uo
        self.lat = lat
        self.lon = lon
        self.vsigns = vsigns
        self.created_by = bywho

    def todict(self):
        d = {}
        for column in self.__table__.columns:
            if column.name == "vsigns":
                d[column.name] = json.loads(getattr(self, column.name))
            else:
                if isinstance(getattr(self, column.name), datetime.datetime):
                    d[column.name] = str(getattr(self, column.name))
                else:
                    d[column.name] = getattr(self, column.name)

        return d


class Image(Base):
    __tablename__ = 'image'

    id = Column(Integer, primary_key=True)
    path = Column(String(16))
    sighting_id = Column(String(16))
    created_by = Column(String(16))

    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow)

    def __init__(self, _id, path, sighting_id, bywho):
        self.id = _id
        self.path = path
        self.sighting_id = sighting_id
        self.created_by = bywho

    def todict(self):
        d = {}
        for column in self.__table__.columns:
            if isinstance(getattr(self, column.name), datetime.datetime):
                d[column.name] = str(getattr(self, column.name))
            else:
                d[column.name] = getattr(self, column.name)
        return d

#------------------------------------------------------------------------------------

def list_all(obj):
    return _sess.query(obj).order_by("created_at").all()

#------------------------------------------------------------------------------------

class BioMapUser:
    def __init__(self, sess):
        self._sess = sess

    def add_user(self, email, password, name, address, occupation, year_hunting):
        _id = int(time.time()*1000000)
        password = hashlib.sha256(password).hexdigest()
        try:
            self._sess.add(User(_id, email, password, name, address, occupation, year_hunting))
            self._sess.commit()
            return _id
        except:
            self._sess.rollback()
            return None

    def get_user(self, email):
        try:
            return self._sess.query(User).filter_by(email=email).first()
        except:
            return None

    def get_user_id(self, uid):
        try:
            return self._sess.query(User).filter_by(id=uid).first()
        except:
            return None

    def update_user_id(self, uid, email, password, name, address, occupation, year_hunting):
        user = self.get_user_id(uid)
        if user:
            user.email = email
            user.passwd = password
            user.name = name
            user.address = address
            user.occupation = occupation
            user.year_hunting = year_hunting
            user.updated_at = datetime.datetime.utcnow()
            self._sess.commit();
        else:
            return None

    def delete_user(self, uid):
        u = self.get_user_id(uid)
        self._sess.delete(u)
        self._sess.commit()


class BioMapSighting:
    def __init__(self, sess):
        self._sess = sess

    def add_sighting(self, an, na, nc, uo, lat, lon, vs, bywho):
        _id = int(time.time()*1000000)
        vs = json.dumps(vs)
        try:
            self._sess.add(Sighting(_id, an, na, nc, uo, lat, lon, vs, bywho))
            self._sess.commit()
            return _id
        except:
            self._sess.rollback()
            return None

    def get_sighting_user(self, uid):
        try:
            return self._sess.query(Sighting).filter_by(created_by=uid)
        except:
            return []

    def get_sighting_id(self, sid):
        try:
            return self._sess.query(Sighting).filter_by(id=sid).first()
        except:
            return None

    def update_sighting_id(self, sid, an, na, nc, uo, lat, lon, vs, bywho):
        sighting = self.get_sighting_id(sid)
        if sighting:
            sighting.animal_name = an
            sighting.no_of_adults = na
            sighting.no_of_calves = nc
            sighting.unusual_observations = uo
            sighting.lat = lat
            sighting.lon = lon
            Sighting.vsigns = json.dumps(vs)
            sighting.created_by = bywho
            sighting.updated_at = datetime.datetime.utcnow()
            self._sess.commit();
        else:
            return None

    def delete_sighting(self, sid):
        s = self.get_sighting_id(sid)
        self._sess.delete(s)
        self._sess.commit()


class BioMapImage:
    def __init__(self, sess):
        self._sess = sess

    def add_image(self, path, sid, bywho):
        _id = int(time.time()*1000000)
        try:
            self._sess.add(Image(_id, path, sid, bywho))
            self._sess.commit()
            return _id
        except:
            self._sess.rollback()
            return None

    def get_images_sighting(self, sid):
        try:
            return self._sess.query(Image).filter_by(sighting_id=sid)
        except:
            return []

    def get_image_id(self, iid):
        try:
            return self._sess.query(Image).filter_by(id=iid).first()
        except:
            return None

    def update_image_id(self, iid, path, sid, bywho):
        image = self.get_image_id(iid)
        if image:
            image.path = path
            image.sighting_id = sid
            image.created_by = bywho
            image.updated_at = datetime.datetime.utcnow()
            self._sess.commit();
        else:
            return None

    def delete_image(self, sid):
        s = self.get_image_id(sid)
        self._sess.delete(s)
        self._sess.commit()


#------------------------------------------------------------------------------------

def add_sighting(na, nc, uo, lat, lon, bywho):
    _id = int(time.time()*1000000)
    _sess.add(Sighting(_id, na, nc, uo, lat, lon, bywho))
    _sess.commit()

#------------------------------------------------------------------------------------

def test1():
    global _sess
    _sess = openDB()

    uid = add_user("leepro1@gmail.com", "leepro")
    print uid
    uid = add_user("leepro2@gmail.com", "leepro")
    print uid
    add_sighting(1, 2, "N/A", 100.00, 200.00, uid)
    add_sighting(0, 1, "N/A", 100.00, 200.00, uid)
    add_sighting(1, 0, "N/A", 100.00, 200.00, uid)

def test2():
    db = openDB()

if __name__ == "__main__":
    test1()
