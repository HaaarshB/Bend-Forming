      SUBROUTINE MPC(UE,A,JDOF,MDOF,N,JTYPE,X,U,UINIT,MAXDOF,LMPC,
     * KSTEP,KINC,TIME,NT,NF,TEMP,FIELD,LTRAN,TRAN)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION UE(MDOF),A(MDOF,MDOF,N),JDOF(MDOF,N),X(6,N),
     * U(MAXDOF,N),UINIT(MAXDOF,N),TIME(2),TEMP(NT,N),
     * FIELD(NF,NT,N),LTRAN(N),TRAN(3,3,N)
C
      IF (KSTEP .EQ. 1) THEN
		LMPC=0
      ELSE
		LMPC=1
		JDOF(1,1)=1
		JDOF(2,1)=2
		JDOF(3,1)=3
		JDOF(4,1)=4
		JDOF(5,1)=5
		JDOF(6,1)=6
		JDOF(1,2)=1
		JDOF(2,2)=2
		JDOF(3,2)=3
		JDOF(4,2)=4
		JDOF(5,2)=5
		JDOF(6,2)=6
C
		A(1,1,1)=1.
		A(2,2,1)=1.
		A(3,3,1)=1.
		A(4,4,1)=1.
		A(5,5,1)=1.
		A(6,6,1)=1.
		A(1,1,2)=-1.
		A(2,2,2)=-1.
		A(3,3,2)=-1.
		A(4,4,2)=-1.
		A(5,5,2)=-1.
		A(6,6,2)=-1.
      ENDIF
C	  
      RETURN
      END

