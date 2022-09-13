<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<title> 공지사항  </title>

<jsp:include page="/WEB-INF/view/common/common_include.jsp"></jsp:include>

<script type="text/javascript">

	// 페이징 설정 
	var pageSize = 5;    	// 화면에 뿌릴 데이터 수 
	var pageBlock = 5;		// 블럭으로 잡히는 페이징처리 수
	
	$(document).ready(function() {
		fn_noticelist();		
		
		fRegisterButtonClickEvent();
	});
	
	function fRegisterButtonClickEvent() {
		$('a[name=btn]').click(function(e) {
			e.preventDefault();

			var btnId = $(this).attr('id');

			switch (btnId) {
				case 'searchBtn' :
					fn_noticelist();
					break;
				case 'btnClose' :
					gfCloseModal();
					break;
				case 'btnSaveNotice' :
					fn_noticesave();
					break;	
				case 'btnDeleteNotice' :
					$("#action").val("D");
					fn_noticesave();
					break;	
				case 'btnSaveNoticedn' :
					fn_noticesavefile();
					break;						
				case 'btnDeleteNoticedn' :
					$("#action").val("D");
					fn_noticesavefile();
					break;	
				case 'btnClosedn' :
					gfCloseModal();
					break;	
			}
		});
		
		var upfile = document.getElementById('upfile');
		upfile.addEventListener('change', 
		function(event){    
							var image = event.target;
							var imgpath = "";
							if(image.files[0])
							{
							alert(window.URL.createObjectURL(image.files[0]));			  
							imgpath =  window.URL.createObjectURL(image.files[0]);
							}	   
							
							//var action = $("#action").val();
							var filearr = $("#upfile").val().split(".");
							
							var previewhtml = "";
							
							if(filearr[1] == "jpg" || filearr[1] == "png") {
							previewhtml = "<img src='" + imgpath + "' style='width: 130px; height: 130px;' />";
							}
							/* 
							if(action == "U") {
							previewhtml = "<a href='javascript:download()'>" + previewhtml + "</a>";
							} */
							
							$("#fileinfo").empty().append(previewhtml);
							//alert(previewhtml);
						}
);
	}	
	
   function 	fn_noticelist(curpage) {
	      
	   curpage = curpage || 1;
	   
	   var param = {
			        title : $("#title").val()
	       ,from_date : $("#from_date").val()  
	       ,to_date : $("#to_date").val()  	
	       ,curpage : curpage
	       ,pageSize : pageSize
	   };
	   
	   var noticelistcallback = function(returndata) {
		    fn_noticelistcallback(returndata,curpage) ;  
	   }
	   
	   callAjax("/system/listnotice.do", "post", "text", true, param, noticelistcallback);
	   
	         
   }
	
   function fn_noticelistcallback(returndata,curpage) {	   
	   console.log(returndata);
	   
	   $("#noticeList").empty().append(returndata);	   
	   var totcnt = $("#totcnt").val();
				
		// 페이지 네비게이션 생성		
		var paginationHtml = getPaginationHtml(curpage, totcnt, pageSize, pageBlock, 'fn_noticelist');
		console.log("paginationHtml : " + paginationHtml);
		$("#pagingnavi").empty().append( paginationHtml );
		
		// 현재 페이지 설정
		$("#currentPage").val(curpage);
   }
   
   function fn_NoticeModal(ann_no) {
	   
	   if (ann_no == null || ann_no=="") {   // 신규
		   fn_forminit();
		   
		   gfModalPop("#notice");
	   } else {
		   //alert(ann_no);
		   fn_selectnotice(ann_no);
	   }
   }
   
   function fn_forminit(noticeModel) {
	   
	   if( noticeModel == "" || noticeModel == null || noticeModel == undefined) {   // 신규
		   $("#loginId").val( $("#swriter").val());
		   $("#loginId").attr("readonly", true);	   
		   $("#noticeTitle").val("");
		   $("#noticeContent").val("");
		   $("#btnDeleteNotice").hide();		
		   
		   $("#action").val("I");
	   } else {
		   $("#loginId").val( $("#swriter").val());
		   $("#loginId").attr("readonly", true);
		   
		   $("#selectannno").val(noticeModel.ann_no);
		   $("#noticeTitle").val(noticeModel.ann_title);
		   $("#noticeContent").val(noticeModel.ann_con);
		   
		   $("#btnDeleteNotice").show();	
		   
		   $("#action").val("U");
	   }
   }
   
   function fn_selectnotice(ann_no) {
	   
	   var param = {
			   ann_no : ann_no
	   };
	   
	   var selectnoticecallback = function(selectresult) {
		    console.log("selectnoticecallback : " + JSON.stringify(selectresult) );
		    
		    fn_forminit(selectresult.noticeModel);
		    
		    gfModalPop("#notice");
	   }
	   
	   callAjax("/system/selectnotice.do", "post", "json", true, param, selectnoticecallback);
   }	
   
   function fn_noticesave() {
	   
	   var param = {
			   loginId :  $("#loginId").val()
			 , noticeTitle : $("#noticeTitle").val()
			 , noticeContent : $("#noticeContent").val()	
			 , annno : $("#selectannno").val()
			 , action : $("#action").val()	
	   }
	   
	   var savenoticecallback = function(savereturn) {
		   console.log("savenoticecallback : " + JSON.stringify(savereturn) );
		   
		   var curpage = 1;
		   
		   /*
		   if($("#action").val() == "U") {
			   curpage = $("#currentPage").val();
		   }
		   */
		   
		   if(savereturn.result == "SUCCESS") {
			   if($("#action").val() == "D") {
				   alert("삭제 되었습니다.");
			   } else {
				   alert("저장 되었습니다.");
			   }
			   
			   gfCloseModal();
			   
			   fn_noticelist(curpage);
		   } else {
			   alert("실패 했습니다.");
		   }
	   }
	   
	   callAjax("/system/savenotice.do", "post", "json", true, param, savenoticecallback);
	   
   }
	   
   function fn_NoticeModalfile(ann_no) {
	   
	   if (ann_no == null || ann_no=="") {   // 신규
		   fn_forminitfile();
		   
		   gfModalPop("#noticefile");
	   } else {
		   //alert(ann_no);
		   fn_selectnoticefile(ann_no);
	   }
   }
   
   function fn_forminitfile(noticeModel) {
	   
	   if( noticeModel == "" || noticeModel == null || noticeModel == undefined) {   // 신규
		   $("#loginIdfile").val( $("#swriter").val());
		   $("#loginIdfile").attr("readonly", true);	   
		   $("#noticeTitlefile").val("");
		   $("#noticeContentfile").val("");
		   $("#btnDeleteNoticefile").hide();		
		   
		   $("#upfile").val("");
		   $("#fileinfo").empty();
		   
		   $("#action").val("I");
	   } else {
		   
		   $("#loginIdfile").val( $("#swriter").val());
		   $("#loginIdfile").attr("readonly", true);
		   
		   $("#selectannnofile").val(noticeModel.ann_no);
		   $("#noticeTitlefile").val(noticeModel.ann_title);
		   $("#noticeContentfile").val(noticeModel.ann_con);
		   
		   $("#btnDeleteNoticefile").show();	
		   $("#ann_no").val(noticeModel.ann_no); 
		   
		   $("#upfile").val("");
		   
           if( noticeModel.att_ori == "" || noticeModel.att_ori == null || noticeModel.att_ori == undefined) { 	 
            	 $("#fileinfo").empty();
           } else {
                 var filearr = noticeModel.att_ori.split(".");
                 var previewhtml = "";
                 if(filearr[1] == "jpg" || filearr[1] == "png") {
                   	previewhtml = "<a href='javascript:download(" + noticeModel.ann_no + ")'>" + "<img src='" + noticeModel.att_nli + "' style='width: 130px; height: 130px;' />" + "</a>";
                 } else {
                	previewhtml = "<a href='javascript:download(" + noticeModel.ann_no + ")'>" + noticeModel.att_ori  + "</a>";
                 }
                    
                 $("#fileinfo").empty().append(previewhtml);
            }
           
		   $("#action").val("U");
	   }
   }
   
   function fn_noticesavefile() {
	   
	   var frm = document.getElementById("myNotice");
	   frm.enctype = 'multipart/form-data';
	   var dataWithFile = new FormData(frm);	

	   var savenoticecallback = function(savereturn) {
		   console.log("savenoticecallback : " + JSON.stringify(savereturn) );
		   
		   var curpage = 1;
		   
		   /*
		   if($("#action").val() == "U") {
			   curpage = $("#currentPage").val();
		   }
		   */
		   
		   if(savereturn.result == "SUCCESS") {
			   if($("#action").val() == "D") {
				   alert("삭제 되었습니다.");
			   } else {
				   alert("저장 되었습니다.");
			   }
			   
			   gfCloseModal();
			   
			   fn_noticelist(curpage);
		   } else {
			   alert("실패 했습니다.");
		   }
	   }	   	   
	   
		callAjaxFileUploadSetFormData("/system/savenoticefile.do", "post", "json", true, dataWithFile, savenoticecallback);
	   
   }   
   
 function fn_selectnoticefile(ann_no) {
	   
	   var param = {
			   ann_no : ann_no
	   };
	   
	   var selectnoticecallback = function(selectresult) {
		    console.log("selectnoticecallback : " + JSON.stringify(selectresult) );
		    
		    fn_forminitfile(selectresult.noticeModel);
		    
		    gfModalPop("#noticefile");
	   }
	   
	   callAjax("/system/selectnotice.do", "post", "json", true, param, selectnoticecallback);
   }	
   
 function download(ann_no) {
	
 	var params = "<input type='hidden' name='ann_no' value='"+ ann_no +"' />";
 	
 	jQuery("<form action='/system/noticedownloadfile.do' method='post'>"+params+"</form>").appendTo('body').submit().remove();
	 
	 
 }
 
 
</script>


</head>
<body>
	<!-- ///////////////////// html 페이지  ///////////////////////////// -->

<form id="myNotice" action="" method="">
	
	<input type="hidden" id="currentPage" value="1">  <!-- 현재페이지는 처음에 항상 1로 설정하여 넘김  -->
	<input type="hidden" name="action" id="action" value=""> 
	<input type="hidden" name="selectannno" id="selectannno" value=""> 
	<input type="hidden" id="swriter"  name="swriter"  value="${loginId}"> <!-- 작성자 session에서 java에서 넘어온값 -->
    <input type="hidden" id="ann_no"  name="ann_no"  value="">
	<div id="wrap_area">

		<h2 class="hidden">header 영역</h2>
		<jsp:include page="/WEB-INF/view/common/header.jsp"></jsp:include>

		<h2 class="hidden">컨텐츠 영역</h2>
		<div id="container">
			<ul>
				<li class="lnb">
					<!-- lnb 영역 --> 
					<jsp:include page="/WEB-INF/view/common/lnbMenu.jsp"></jsp:include> <!--// lnb 영역 -->
				</li>
				<li class="contents">
					<!-- contents -->
					<h3 class="hidden">contents 영역</h3> <!-- content -->
					<div class="content">

						<p class="Location">
							<a href="#" class="btn_set home">메인으로</a> 
							<a href="#" class="btn_nav bold">시스템 관리</a> 
								<span class="btn_nav bold">공지 사항</span> 
								<a href="#" class="btn_set refresh">새로고침</a>
						</p>

						<p class="conTitle">
							<span>공지 사항 </span> <span class="fr"> 
								<c:set var="nullNum" value=""></c:set>
								<a class="btnType blue" href="javascript:fn_NoticeModal();" name="modal">
								<span>신규등록</span></a>
								<a class="btnType blue" href="javascript:fn_NoticeModalfile();" name="modal">
								<span>신규등록(파일)</span></a>
							</span>
						</p>
						
					<!--검색창  -->
					<table width="100%" cellpadding="5" cellspacing="0" border="1"
                        align="left"
                        style="border-collapse: collapse; border: 1px #50bcdf;">
                        <tr style="border: 0px; border-color: blue">
                           <td width="100" height="25" style="font-size: 120%">&nbsp;&nbsp;</td>

                           <td width="50" height="25" style="font-size: 100%">제목</td>
                           <td width="50" height="25" style="font-size: 100%">
                               <input type="text" style="width: 120px" id="title" name="title"></td>                     
                           <td width="50" height="25" style="font-size: 100%">작성일</td>
                           <td width="50" height="25" style="font-size: 100%">
                            <input type="date" style="width: 120px" id="from_date" name="from_date"></td>
                           <td width="50" height="25" style="font-size: 100%">
                            <input type="date" style="width: 120px" id="to_date" name="to_date"></td>
                           <td width="110" height="60" style="font-size: 120%">
                           <a href="" class="btnType blue" id="searchBtn" name="btn"><span>검  색</span></a></td> 
                            <!-- <input type="button" value="검  색  " id="searchBtn" name="btn" class="test_btn1" 
                              style="border-collapse: collapse; border: 0px gray solid; background-color: #50bcdf; width: 70px; color: white"/> -->
                        </tr>
                     </table>    
						
						
						<div class="divNoticeList">
							<table class="col">
								<caption>caption</caption>
	
		                            <colgroup>
						                   <col width="10%">
						                   <col width="60%">
						                   <col width="10%">
						                   <col width="10%">
						                   <col width="10%">
					                 </colgroup>
								<thead>
									<tr>
							              <th scope="col">공지 번호</th>
							              <th scope="col">공지 제목</th>
							              <th scope="col">공지 날짜</th>
							              <th scope="col">작성자</th>
							              <th scope="col">조회수</th>
									</tr>
								</thead>
								<tbody id="noticeList"></tbody>
							</table>
							
							<!-- 페이징 처리  -->
							<div class="paging_area" id="pagingnavi">
							</div>
											
						</div>

		
					</div> <!--// content -->

					<h3 class="hidden">풋터 영역</h3>
						<jsp:include page="/WEB-INF/view/common/footer.jsp"></jsp:include>
				</li>
			</ul>
		</div>
	</div>


	<!-- 모달팝업 -->
	<div id="notice" class="layerPop layerType2" style="width: 600px;">
		<input type="hidden" id="noticeNo" name="noticeNo" value="${noticeNo}"> <!-- 수정시 필요한 num 값을 넘김  -->
		
		<dl>
			<dt>
				<strong>공지사항</strong>
			</dt>
			<dd class="content">
				<!-- s : 여기에 내용입력 -->
				<table class="row">
					<caption>caption</caption>

					<tbody>
						<tr>
							<th scope="row">작성자 <span class="font_red">*</span></th>
							<td><input type="text" class="inputTxt p100" name="loginId" id="loginId" /></td>
						</tr>
						<tr>
							<th scope="row">제목 <span class="font_red">*</span></th>
							<td colspan="3"><input type="text" class="inputTxt p100"
								name="noticeTitle" id="noticeTitle" /></td>
						</tr>
						<tr>
							<th scope="row">내용</th>
							<td colspan="3">
								<textarea class="inputTxt p100" name="noticeContent" id="noticeContent">
								</textarea>
							</td>
						</tr>
						
					</tbody>
				</table>

				<!-- e : 여기에 내용입력 -->

				<div class="btn_areaC mt30">
					<a href="" class="btnType blue" id="btnSaveNotice" name="btn"><span>저장</span></a> 
					<a href="" class="btnType blue" id="btnUpdateNotice" name="btn" style="display:none"><span>수정</span></a> 
					<a href="" class="btnType blue" id="btnDeleteNotice" name="btn"><span>삭제</span></a> 
					<a href=""	class="btnType gray"  id="btnClose" name="btn"><span>취소</span></a>
				</div>
			</dd>

		</dl>
		<a href="" class="closePop"><span class="hidden">닫기</span></a>
	</div>
	
	<!-- 모달팝업 -->
	<div id="noticefile" class="layerPop layerType2" style="width: 600px;">
		<input type="hidden" id="noticeNo" name="noticeNo" value="${noticeNo}"> <!-- 수정시 필요한 num 값을 넘김  -->
		
		<dl>
			<dt>
				<strong>공지사항</strong>
			</dt>
			<dd class="content">
				<!-- s : 여기에 내용입력 -->
				<table class="row">
					<caption>caption</caption>

					<tbody>
						<tr>
							<th scope="row">작성자 <span class="font_red">*</span></th>
							<td><input type="text" class="inputTxt p100" name="loginIdfile" id="loginIdfile" /></td>
						</tr>
						<tr>
							<th scope="row">제목 <span class="font_red">*</span></th>
							<td colspan="3"><input type="text" class="inputTxt p100"
								name="noticeTitlefile" id="noticeTitlefile" /></td>
						</tr>
						<tr>
							<th scope="row">내용</th>
							<td colspan="3">
								<textarea class="inputTxt p100" name="noticeContentfile" id="noticeContentfile">
								</textarea>
							</td>
						</tr>

						<tr>
							<th scope="row">파일</th>
							<td>
								<input type="file" id="upfile"  name="upfile"   />
							</td>
							<td colspan=2>
							    <div id="fileinfo">
							    </div>
							</td>
							
						</tr>
						
					</tbody>
				</table>

				<!-- e : 여기에 내용입력 -->

				<div class="btn_areaC mt30">
					<a href="" class="btnType blue" id="btnSaveNoticedn" name="btn"><span>저장</span></a> 
					<a href="" class="btnType blue" id="btnUpdateNoticedn" name="btn" style="display:none"><span>수정</span></a> 
					<a href="" class="btnType blue" id="btnDeleteNoticedn" name="btn"><span>삭제</span></a> 
					<a href=""	class="btnType gray"  id="btnClosedn" name="btn"><span>취소</span></a>
				</div>
			</dd>

		</dl>
		<a href="" class="closePop"><span class="hidden">닫기</span></a>
	</div>	


</form>

</body>
</html>
