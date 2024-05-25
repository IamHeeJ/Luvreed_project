import './manage.css';
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Header from '../0header/header';
import searchIcon from '../img/search.png';
import linked from '../img/linked.png';

export default function Manage() {
  const [users, setUsers] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [postsPerPage] = useState(20); 
  const [searchTerm, setSearchTerm] = useState('');
  const [modalOpen, setModalOpen] = useState(false); 
  const [selectedCoupleMembers, setSelectedCoupleMembers] = useState([]);
  const [selectedCoupleMembersid, setSelectedCoupleMembersid] = useState([]);
  useEffect(() => {
    fetchUserList();
  }, []);

  const fetchUserList = async () => {
    try {
      const adminToken = sessionStorage.getItem('token');
      const response = await axios.get('/api/web/admin/accountlist', {
        headers: {
          Authorization: 'Bearer ' + adminToken
        }
      });
      setUsers(response.data);
    } catch (error) {
      console.error('Error fetching user list:', error);
    }
    
  };

// 사용자 목록을 커플 아이디로 그룹화
const groupedUsers = users.reduce((groups, user) => {
  const groupId = user.coupleId;
  // coupleId가 null이 아닌 경우에만 그룹화
  if (groupId !== null && groupId !== undefined) {
    if (!groups[groupId]) {
      groups[groupId] = [];
    }
    groups[groupId].push(user);
  }
  return groups;
}, {});

  // 검색어를 이용한 사용자 필터링
  // const filteredGroups = Object.values(groupedUsers).filter(group =>
  //   group.some(user => user.name.toLowerCase().includes(searchTerm.toLowerCase()) || user.email.toLowerCase().includes(searchTerm.toLowerCase()))
  // );

  const filteredGroups = Object.values(groupedUsers).filter(group =>
    group.some(user => {
      if (user.name && user.email) {
        return user.name.toLowerCase().includes(searchTerm.toLowerCase()) || user.email.toLowerCase().includes(searchTerm.toLowerCase());
      }
      return false;
    })
  );
  

  // 페이지 변경
  const paginate = pageNumber => setCurrentPage(pageNumber);

  const totalGroups = filteredGroups.length;
  const groupsPerPage = 10;
  const startIndex = (currentPage - 1) * groupsPerPage;
  const endIndex = Math.min(startIndex + groupsPerPage, totalGroups);
  const currentGroups = filteredGroups.slice(startIndex, endIndex);

  // 클라이언트에서 deleteCouple 함수 수정
  const deleteCouple = async (userId, loverId) => {
    try {
      const adminToken = sessionStorage.getItem('token');
      await axios.delete(`/api/web/admin/deletecoupleaccount?userId=${userId}&loverId=${loverId}`, {
        headers: {
          Authorization: 'Bearer ' + adminToken
        }
      });
      // 삭제 후 사용자 목록 다시 가져오기
      fetchUserList();
      closeModal(); // 모달 닫기
    } catch (error) {
      console.error('Error deleting couple:', error);
    }
  };

  // 솔로 계정 삭제 함수
  const deleteSoloAccount = async (userId) => {
    try {
      const adminToken = sessionStorage.getItem('token');
      await axios.get(`/api/web/admin/deletesoloaccount?userId=${userId}`, {
        headers: {
          Authorization: 'Bearer ' + adminToken
        }
      });
      // 삭제 후 사용자 목록 다시 가져오기
      fetchUserList();
      closeModal(); // 모달 닫기
    } catch (error) {
      console.error('Error deleting solo account:', error);
    }
  };

  // 각 커플 행 클릭 시 모달 열기 함수
  const openModal = (group) => {
    if (group.length === 1) {
      setModalOpen(true);
      setSelectedCoupleMembers(group.map(user => user.name));
      setSelectedCoupleMembersid(group.map(user => user.id));
    } else {
      // 그룹에 두 명 이상이 있으면 커플 삭제 함수 호출
      setModalOpen(true);
      setSelectedCoupleMembers(group.map(user => user.name));
      setSelectedCoupleMembersid(group.map(user => user.id));
    }
  };
  const handleDelete = () => {
    console.log("handleDelete가 호출되었습니다.");
    console.log("selectedCoupleMembers:", selectedCoupleMembers);
    console.log("selectedCoupleMembersid:", selectedCoupleMembersid);
    
    const [firstUser, secondUser] = selectedCoupleMembersid;
    console.log("firstUserid:", firstUser);
    console.log("secondUserid:", secondUser);
    if (secondUser) {
      // 그룹에 두 명이 있으면 커플 삭제 함수 호출
      deleteCouple(firstUser, secondUser);
    } else {
      // 그룹에 한 명이 있으면 솔로 계정 삭제 함수 호출
      deleteSoloAccount(firstUser);
    }
  };

  // 모달 닫기 함수
  const closeModal = () => {
    // 모달이 닫힐 때 선택된 커플의 회원 목록 초기화
    setSelectedCoupleMembers([]);
    setModalOpen(false);
  };


  return (
    <div className="Main">
      <Header />
      <main className="manage-container">
        <div className="header-content">
          <div className='list-title'>회원목록</div>
          <div className="search-bar">
            <img src={searchIcon} alt="Search" className="search-icon" />
            <input 
              type="text"
              className="search-input"
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
        </div>
        <div className='table-header' />
        <table className="member-table">
          <thead>
            <tr>
              <th>이름</th>
              <th>이메일</th>
              <th>
                <img src={linked} alt="Linked" />
              </th>
              <th>이름</th>
              <th>이메일</th>
            </tr>
          </thead>
          <tbody>
              {currentGroups.map((group, index) => (
                <tr key={index} onClick={() => openModal(group)}>
                  {group.map((user, innerIndex) => (
                    <React.Fragment key={innerIndex}>
                      <td>{user.name}</td>
                      <td>{user.email}</td>
                      <td></td>
                    </React.Fragment>
                  ))}
                  {group.length < 2 && (
                    <>
                      <td></td>
                      <td></td>
                    </>
                  )}
                </tr>
              ))}
              {/* coupleId가 null인 사용자를 표시 */}
              {users.filter(user => user.coupleId === null).map((user, index) => (
                <tr key={`null_${index}`} onClick={() => openModal([user])}>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td></td>
                </tr>
              ))}
        </tbody>
      </table>
        <Pagination
          postsPerPage={postsPerPage}
          totalPosts={filteredGroups.flat().length}
          paginate={paginate}
          currentPage={currentPage}
        />
      </main>
      {modalOpen && (
        <div className="modal" onClick={() => closeModal()}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <p>{selectedCoupleMembers.join(', ')} 회원을 삭제하시겠습니까?</p>
            <div className="modal-button">
              <button className="delete" onClick={handleDelete}>삭제</button>
              <button className="close" onClick={() => closeModal()}>유지</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// 페이지네이션 컴포넌트
const Pagination = ({ postsPerPage, totalPosts, currentPage, paginate }) => {
  const pageNumbers = [];

  for (let i = 1; i <= Math.ceil(totalPosts / postsPerPage); i++) {
    pageNumbers.push(i);
  }

  return (
    <div className="pagination">
      {pageNumbers.map(number => (
        <div
          key={number}
          className={`page-num ${currentPage === number ? 'current-page' : ''}`}
          onClick={() => paginate(number)}
        >
          {number}
        </div>
      ))}
    </div>
  );
};