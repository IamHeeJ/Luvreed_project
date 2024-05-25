import logo from '../img/luvreed.png';
import './header.css';
import React, { useState, useEffect } from 'react';
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom';

const activeStyle = {
  color: 'black',
};

export default function Header() {
  const location = useLocation();
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    const token = sessionStorage.getItem('token');
    if (token) {
      setIsLoggedIn(true);
    } else {
      setIsLoggedIn(false);
    }
  }, []);

  const handleLogout = () => {
    sessionStorage.removeItem("token");
    sessionStorage.removeItem("email");
    sessionStorage.removeItem("role");
    sessionStorage.removeItem("storeid");
    setIsLoggedIn(false);
  };

  const handleServiceClick = (event) => {
    if (!isLoggedIn) {
      event.preventDefault(); // 링크 클릭의 기본 동작 방지
      alert('관리자 권한이 필요합니다. 로그인을 해주세요.');
      navigate('/login'); // 로그인 페이지로 이동
    }
  };

  return (
    <div className="header">
      <header className="navbar">
        <div className="nav-left">
          <div className="logo">
            <img src={logo} alt="Luvreed Logo" className="nav-logo"/>
          </div>
          <div className="nav-links">
            <NavLink style={({ isActive }) => (isActive ? activeStyle : {})}  to="/" exact>소개해요</NavLink>
            <NavLink style={({ isActive }) => (isActive ? activeStyle : {})}  to="/aiservice" onClick={handleServiceClick}>AI 서비스</NavLink>
            <NavLink style={({ isActive }) => (isActive ? activeStyle : {})}  to="/manage" onClick={handleServiceClick}>회원관리</NavLink>
            <NavLink style={({ isActive }) => (isActive ? activeStyle : {})}  to="/operate" onClick={handleServiceClick}>유지보수</NavLink>
          </div>
        </div>
        <div className="nav-right">
          <div className="user-actions">
            {isLoggedIn ? (
              <>
                <Link to="/login" className='btnLink' onClick={handleLogout}>
                  로그아웃
                </Link>
              </>
            ) : (
              <Link to="/login" className='btnLink'>
                로그인
              </Link>
            )}
            <Link to="/download">
              <button>앱 다운로드</button>
            </Link>
          </div>
        </div>
      </header>
    </div>
  );
}
