#include <assert.h>
#include <unistd.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/types.h>
#include <pthread.h>
#include <semaphore.h>
#include <SDL/SDL.h>

#define SDL_NETWORK_EVENT 25

static pthread_t net_thread ; /* Network thread id */
static sem_t q_avail ; /* Slots available in the queue (binary semaphore) */
static int net_socket ; /* Socket being select()'ed */
static int running = 0 ; /* True iff network thread is active */

/* Network event generator thread */
static void *put_net_event (void *arg) {

    fd_set set ;
    int result = 0 ;
    SDL_Event event ;

    event.type = 25 ;

    while (1) {
        result = 0 ;

        /* Wait for permission */
        sem_wait (&q_avail) ;

        /* Wait for network activity */
        while (result==0 || result==EINTR) {
            FD_ZERO (&set) ;
            FD_SET (net_socket, &set) ;
            result = select (FD_SETSIZE, &set, NULL, NULL, NULL);
        }

        if (result<=0)
            pthread_exit (NULL);
        else { /* Put event */
            while (0 >= SDL_PushEvent (&event))
                SDL_Delay (10) ;
        }
        pthread_testcancel() ;
    }
}

/* Start network thread */
int init_netevent_thread (int s) {

    int result = 0 ;

    if (!running) {
        net_socket = s ;
        result = sem_init (&q_avail, 0, 1) ;
        if (result) return result ;
        result = pthread_create (&net_thread, NULL, put_net_event, NULL) ;
        if (result==0)
            running = 1 ;
        return result ;
    } else return -1 ;
}

/* Stop network thread */
int stop_netevent_thread (void) {
    int result = 0 ;

    if (running) {
        result = pthread_cancel (net_thread) ;
        assert (result == 0) ;
        result = pthread_join (net_thread, NULL) ;
        if (result) return result ;
        result = sem_destroy (&q_avail) ;
        if (result) return result ;
        running = 0 ;
    }
    return result ;
}

/* Acknowledge network event */
void netevent_ack (void) {
    sem_post (&q_avail) ;
}
