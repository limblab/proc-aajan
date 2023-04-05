import numpy as np
import math
import matplotlib.pyplot as plt

def calc_joint_angle(kp1, kp2, kp3):
	# vectors must be tail to tail to calculate joint angles
	l1 = kp1 - kp2
	l2 = kp3 - kp2

	# print(l1, l2)

	l1_norm = np.linalg.norm(l1)
	l2_norm = np.linalg.norm(l2)
	norm = l1_norm*l2_norm
	dot = np.dot(l1,l2)

	# print(dot, norm)
	theta = math.acos(dot/norm)
	theta = math.degrees(theta)
	return(theta)

def get_joint_angles(data):

	# set up landmarks
	pinky_t = np.array([1-1,2-1,3-1])
	pinky_d = np.array([4-1,5-1,6-1])
	pinky_m = np.array([7-1,8-1,9-1])
	pinky_p = np.array([10-1,11-1,12-1])

	ring_t = np.array([13-1,14-1,15-1])
	ring_d = np.array([16-1,17-1,18-1])
	ring_m = np.array([19-1,20-1,21-1])
	ring_p = np.array([22-1,23-1,24-1])

	middle_t = np.array([25-1,26-1,27-1])
	middle_d = np.array([28-1,29-1,30-1])
	middle_m = np.array([31-1,32-1,33-1])
	middle_p = np.array([34-1,35-1,36-1])

	index_t = np.array([37-1,38-1,39-1])
	index_d = np.array([40-1,41-1,42-1])
	index_m = np.array([43-1,44-1,45-1])
	index_p = np.array([46-1,47-1,48-1])

	thumb_t = np.array([49-1,50-1,51-1])
	thumb_d = np.array([52-1,53-1,54-1])
	thumb_m = np.array([55-1,56-1,57-1])
	thumb_p = np.array([58-1,59-1,60-1])

	palm = np.array([61-1,62-1,63-1])
	wrist_u = np.array([64-1,65-1,66-1])
	wrist_r = np.array([67-1,68-1,69-1])

	# set up angles
	pinky_d_angle = np.zeros(data.shape[0])
	pinky_m_angle = np.zeros(data.shape[0])
	pinky_p_angle = np.zeros(data.shape[0])

	ring_d_angle = np.zeros(data.shape[0])
	ring_m_angle = np.zeros(data.shape[0])
	ring_p_angle = np.zeros(data.shape[0])

	middle_d_angle = np.zeros(data.shape[0])
	middle_m_angle = np.zeros(data.shape[0])
	middle_p_angle = np.zeros(data.shape[0])

	index_d_angle = np.zeros(data.shape[0])
	index_m_angle = np.zeros(data.shape[0])
	index_p_angle = np.zeros(data.shape[0])

	thumb_d_angle = np.zeros(data.shape[0])
	thumb_m_angle = np.zeros(data.shape[0])
	thumb_p_angle = np.zeros(data.shape[0])

	for frame in range(data.shape[0]):
		pinky_d_angle[frame] = calc_joint_angle(data[frame,pinky_t],data[frame,pinky_d],data[frame,pinky_m])
		pinky_m_angle[frame] = calc_joint_angle(data[frame,pinky_d],data[frame,pinky_m],data[frame,pinky_p])
		pinky_p_angle[frame] = calc_joint_angle(data[frame,pinky_m],data[frame,pinky_p],data[frame,palm])

		ring_d_angle[frame] = calc_joint_angle(data[frame,ring_t],data[frame,ring_d],data[frame,ring_m])
		ring_m_angle[frame] = calc_joint_angle(data[frame,ring_d],data[frame,ring_m],data[frame,ring_p])
		ring_p_angle[frame] = calc_joint_angle(data[frame,ring_m],data[frame,ring_p],data[frame,palm])

		middle_d_angle[frame] = calc_joint_angle(data[frame,middle_t],data[frame,middle_d],data[frame,middle_m])
		middle_m_angle[frame] = calc_joint_angle(data[frame,middle_d],data[frame,middle_m],data[frame,middle_p])
		middle_p_angle[frame] = calc_joint_angle(data[frame,middle_m],data[frame,middle_p],data[frame,palm])

		index_d_angle[frame] = calc_joint_angle(data[frame,index_t],data[frame,index_d],data[frame,index_m])
		index_m_angle[frame] = calc_joint_angle(data[frame,index_d],data[frame,index_m],data[frame,index_p])
		index_p_angle[frame] = calc_joint_angle(data[frame,index_m],data[frame,index_p],data[frame,palm])

		thumb_d_angle[frame] = calc_joint_angle(data[frame,thumb_t],data[frame,thumb_d],data[frame,thumb_m])
		thumb_m_angle[frame] = calc_joint_angle(data[frame,thumb_d],data[frame,thumb_m],data[frame,thumb_p])
		thumb_p_angle[frame] = calc_joint_angle(data[frame,thumb_m],data[frame,thumb_p],data[frame,wrist_r]) 


	angles = np.c_[pinky_d_angle,pinky_m_angle,pinky_p_angle
						,ring_d_angle,ring_m_angle,ring_p_angle
						,middle_d_angle,middle_m_angle,middle_p_angle
						,index_d_angle,index_m_angle,index_p_angle
						,thumb_d_angle,thumb_m_angle,thumb_p_angle]

	# angles = np.reshape(angles, (-1, 5, 3))
	return(angles)

def get_joint_velocities(angles):
	velocity = np.diff(angles, axis = 0)/0.033333
	lastrow = np.expand_dims(velocity[-1], axis = 0)
	velocity = np.append(velocity, lastrow, axis = 0)
	return(velocity)

def plot_angles_hist(angles, date, bins = 400):
	titles = [['Pinky DIP','Pinky PIP','Pinky MCP'],
				['Ring DIP','Ring PIP','Ring MCP'],
				['Middle DIP','Middle PIP','Middle MCP'],
				['Index DIP','Index PIP','Index MCP'],
				['Thumb DIP','Thumb PIP','Thumb MCP']]

	fig, ax = plt.subplots(nrows = 5, ncols = 3)
	fig.set_size_inches(20, 20)
	fig.suptitle('Pop Joint Angles - ' + date)
	for i in range(ax.shape[0]):
		for j in range(ax.shape[1]):
			ax[i][j].hist(angles[:,i,j], bins = bins)
			ax[i][j].set_title(titles[i][j])
	plt.show()

def plot_angles_timeplot(angles, date, time_range):
	titles = [['Pinky DIP','Pinky PIP','Pinky MCP'],
				['Ring DIP','Ring PIP','Ring MCP'],
				['Middle DIP','Middle PIP','Middle MCP'],
				['Index DIP','Index PIP','Index MCP'],
				['Thumb IP','Thumb MP','Thumb CMC']]

	fig, ax = plt.subplots(nrows = 5, ncols = 3)
	fig.set_size_inches(20, 20)
	fig.suptitle('Pop Joint Angles - ' + date)
	for i in range(ax.shape[0]):
		for j in range(ax.shape[1]):
			ax[i][j].plot(angles[time_range[0]:time_range[1],i,j])
			ax[i][j].set_title(titles[i][j])
	plt.show()
